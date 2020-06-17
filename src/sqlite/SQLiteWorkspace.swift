import Dflat
import SQLite3
import Dispatch
import Foundation

public final class SQLiteWorkspace: Workspace {

  public enum FileProtectionLevel: Int32 {
    case noProtection = 4 // Class D
    case completeFileProtection = 1 // Class A
    case completeFileProtectionUnlessOpen = 2 // Class B
    case completeFileProtectionUntilFirstUserAuthentication = 3 // Class C
  }
  private let filePath: String
  private let fileProtectionLevel: FileProtectionLevel
  private let queue: DispatchQueue
  private var writer: SQLiteConnection?
  private let readerPool: SQLiteConnectionPool
  private let state = SQLiteWorkspaceState()
  private var resultPublishers = [ObjectIdentifier: ResultPublisher]()

  public required init(filePath: String, fileProtectionLevel: FileProtectionLevel, queue: DispatchQueue = DispatchQueue(label: "com.dflat.write", qos: .utility)) {
    self.filePath = filePath
    self.fileProtectionLevel = fileProtectionLevel
    self.queue = queue
    self.readerPool = SQLiteConnectionPool(capacity: 64, filePath: filePath)
    queue.async { [weak self] in
      self?.prepareData()
    }
  }

  // MARK - Mutation

  public func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping Workspace.ChangesHandler, completionHandler: Workspace.CompletionHandler? = nil) {
    queue.async { [weak self] in
      self?.invokeChangesHandler(transactionalObjectTypes, changesHandler: changesHandler, completionHandler: completionHandler)
    }
  }

  // MARK - Fetching

  private struct Snapshot {
    var reader: SQLiteConnectionPool.Borrowed
    var changesTimestamp: Int64
  }

  static private var snapshot: Snapshot? {
    get {
      Thread.current.threadDictionary["SQLiteSnapshot"] as? Snapshot
    }
    set(newSnapshot) {
      Thread.current.threadDictionary["SQLiteSnapshot"] = newSnapshot
    }
  }

  public func fetchFor<Element: Atom>(_ ofType: Element.Type) -> QueryBuilder<Element> {
    if let txnContext = SQLiteTransactionContext.current {
      precondition(txnContext.contains(ofType: ofType))
      return SQLiteQueryBuilder<Element>(reader: txnContext.borrowed, transactionContext: txnContext, changesTimestamp: txnContext.changesTimestamp)
    }
    if let snapshot = Self.snapshot {
      return SQLiteQueryBuilder<Element>(reader: snapshot.reader, transactionContext: nil, changesTimestamp: snapshot.changesTimestamp)
    }
    let changesTimestamp = state.changesTimestamp.load(order: .acquire)
    return SQLiteQueryBuilder<Element>(reader: readerPool.borrow(), transactionContext: nil, changesTimestamp: changesTimestamp)
  }
  
  public func fetchWithinASnapshot<T>(_ closure: () -> T, ofType: T.Type) -> T {
    // If I am in a write transaction, it is a consistent view already.
    if SQLiteTransactionContext.current != nil {
      return closure()
    }
    // Require a consistent snapshot by starting a transaction.
    let reader = readerPool.borrow()
    let changesTimestamp = state.changesTimestamp.load(order: .acquire)
    Self.snapshot = Snapshot(reader: reader, changesTimestamp: changesTimestamp)
    guard let pointee = reader.pointee else {
      let retval = closure()
      Self.snapshot = nil
      return retval
    }
    let begin = pointee.prepareStatement("BEGIN")
    sqlite3_step(begin)
    let retval = closure()
    let release = pointee.prepareStatement("RELEASE")
    sqlite3_step(release)
    Self.snapshot = nil
    return retval
  }

  // MARK - Observation

  public func subscribe<Element: Atom>(fetchedResult: FetchedResult<Element>, changeHandler: @escaping (_: FetchedResult<Element>) -> Void) -> Workspace.Subscription {
    let identifier = ObjectIdentifier(fetchedResult)
    let subscription = SQLiteSubscription(ofType: .fetchedResult(Element.self, identifier), identifier: ObjectIdentifier(changeHandler as AnyObject), workspace: self)
    queue.async { [weak self] in
      guard let self = self else { return }
      let identifier = ObjectIdentifier(Element.self)
      // TODO: Need to check changesTimestamp and possibly refetch in case it is updated.
      let resultPublisher: SQLiteResultPublisher<Element>
      if let pub = self.resultPublishers[identifier] {
        resultPublisher = pub as! SQLiteResultPublisher<Element>
      } else {
        resultPublisher = SQLiteResultPublisher()
        self.resultPublishers[identifier] = resultPublisher
      }
      resultPublisher.subscribe(fetchedResult: fetchedResult as! SQLiteFetchedResult<Element>, changeHandler: changeHandler, subscription: subscription)
    }
    return subscription
  }

  public func subscribe<Element: Atom>(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void) -> Workspace.Subscription {
    let subscription = SQLiteSubscription(ofType: .object(Element.self, object._rowid), identifier: ObjectIdentifier(changeHandler as AnyObject), workspace: self)
    queue.async { [weak self] in
      guard let self = self else { return }
      guard let writer = self.writer else { return }
      let identifier = ObjectIdentifier(Element.self)
      let changesTimestamp = self.state.tableTimestamps[identifier] ?? -1
      if object._changesTimestamp < changesTimestamp {
        // Since the object is out of date, now we need to check whether we need to call changeHandler immediately.
        let fetchedObject = SQLiteObjectRepository.object(writer, ofType: Element.self, for: .rowid(object._rowid) as SQLiteObjectKey<Int64>)
        guard let updatedObject = fetchedObject else {
          subscription.cancelled.store(true)
          changeHandler(.deleted)
          return
        }
        if object != updatedObject { // If object changed, call update.
          updatedObject._changesTimestamp = changesTimestamp
          changeHandler(.updated(updatedObject))
        }
      }
      let resultPublisher: SQLiteResultPublisher<Element>
      if let pub = self.resultPublishers[identifier] {
        resultPublisher = pub as! SQLiteResultPublisher<Element>
      } else {
        resultPublisher = SQLiteResultPublisher()
        self.resultPublishers[identifier] = resultPublisher
      }
      resultPublisher.subscribe(object: object, changeHandler: changeHandler, subscription: subscription)
    }
    return subscription
  }
  
  func cancel(ofType: SQLiteSubscriptionType, identifier: ObjectIdentifier) {
    queue.async { [weak self] in
      switch ofType {
      case let .fetchedResult(atomType, fetchedResult):
        guard let resultPublisher = self?.resultPublishers[ObjectIdentifier(atomType)] else { return }
        resultPublisher.cancel(fetchedResult: fetchedResult, identifier: identifier)
      case let .object(atomType, rowid):
        guard let resultPublisher = self?.resultPublishers[ObjectIdentifier(atomType)] else { return }
        resultPublisher.cancel(object: rowid, identifier: identifier)
      }
    }
  }

  // MARK - Internal

  static func setUpFilePathWithProtectionLevel(filePath: String, fileProtectionLevel: FileProtectionLevel) {
    #if !targetEnvironment(simulator)
    let fd = open_dprotected_np(filePath, O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0, 0666)
    close(fd)
    let wal = open_dprotected_np(filePath + "-wal", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0, 0666)
    close(wal)
    let shm = open_dprotected_np(filePath + "-shm", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0, 0666)
    close(shm)
    #endif
  }
  
  private func prepareData() {
    dispatchPrecondition(condition: .onQueue(queue))
    // Set the flag before creating the s
    Self.setUpFilePathWithProtectionLevel(filePath: filePath, fileProtectionLevel: fileProtectionLevel)
    writer = SQLiteConnection(filePath: filePath, createIfMissing: true)
    guard let writer = writer else { return }
    sqlite3_busy_timeout(writer.sqlite, 10_000)
    sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
    sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
    sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
  }

  private func invokeChangesHandler(_ transactionalObjectTypes: [Any.Type], changesHandler: Workspace.ChangesHandler, completionHandler: Workspace.CompletionHandler?) {
    guard let writer = writer else {
      completionHandler?(false)
      return
    }
    let changesTimestamp = state.changesTimestamp.load(order: .acquire)
    let txnContext = SQLiteTransactionContext(state: state, objectTypes: transactionalObjectTypes, writer: writer, changesTimestamp: changesTimestamp)
    let begin = writer.prepareStatement("BEGIN")
    guard SQLITE_DONE == sqlite3_step(begin) else {
      completionHandler?(false)
      return
    }
    changesHandler(txnContext)
    let updatedObjects = txnContext.objectRepository.updatedObjects
    txnContext.destroy()
    let commit = writer.prepareStatement("COMMIT")
    let status = sqlite3_step(commit)
    if SQLITE_FULL == status {
      let rollback = writer.prepareStatement("ROLLBACK")
      let status = sqlite3_step(rollback)
      precondition(status == SQLITE_DONE)
      completionHandler?(false)
      return
    }
    precondition(status == SQLITE_DONE)
    var reader: SQLiteConnectionPool.Borrowed? = nil
    let newChangesTimestamp = state.changesTimestamp.increment(order: .release) + 1 // Return the previously hold timestamp, thus, the new timestamp need + 1
    for (identifier, updates) in updatedObjects {
      state.tableTimestamps[identifier] = newChangesTimestamp
      guard let resultPublisher = resultPublishers[identifier] else { continue }
      if reader == nil {
        reader = SQLiteConnectionPool.Borrowed(pointee: writer)
      }
      guard let reader = reader else { continue }
      resultPublisher.publishUpdates(updates, reader: reader, changesTimestamp: newChangesTimestamp)
    }
    completionHandler?(true)
  }
}
