import Atomics
import Dflat
import Dispatch
import FlatBuffers
import Foundation
import SQLite3
import _SQLiteDflatOSShim

public final class SQLiteWorkspace: Workspace {

  public enum FileProtectionLevel: Int32 {
    /**
     * Class D: No protection. If the device is booted, in theory, you can access the content.
     * When it is not booted, the content is protected by the Secure Enclave's hardware key.
     */
    case noProtection = 4  // Class D
    /**
     * Class A: The file is accessible if the phone is unlocked and the app is in foreground.
     * You will lose the file access if the app is backgrounded or the phone is locked.
     */
    case completeFileProtection = 1  // Class A
    /**
     * Class B: The file is accessible if the phone is unlocked. You will lose the file access
     * if the phone is locked.
     */
    case completeFileProtectionUnlessOpen = 2  // Class B
    /**
     * Class C: The file is accessible once user unlocked the phone once. The file cannot be
     * accessed prior to that. For example, if you received a notification before first device
     * unlock, the underlying database cannot be open successfully.
     */
    case completeFileProtectionUntilFirstUserAuthentication = 3  // Class C
  }
  public enum WriteConcurrency {
    /**
     * Enable strict serializable multi-writer / multi-reader mode. Note that SQLite under the
     * hood still writes serially. It only means the transaction closures can be executed
     * concurrently. If you provided a targetQueue, please make sure it is a concurrent queue
     * otherwise it will still execute transaction closure serially. The targetQueue is supplied
     * by you, should be at reasonable priority, at least `.default`, because it sets the ceiling
     * for any sub-queues targeting that, and we may need to bump the sub-queues depending on
     * where you `performChanges`.
     */
    case concurrent
    /**
     * Enable single-writer / multi-reader mode. This will execute transaction closures serially.
     * If you supply a targetQueue, please make sure it is serial. It is safe for this serial queue
     * to have lower priority such as `.utility`, because we can bump the priority based on where
     * you call `performChanges`.
     */
    case serial
  }
  /**
     * The synchronous mode of SQLite. We defaults to `.normal`. Read more on: [https://www.sqlite.org/wal.html#performance_considerations](https://www.sqlite.org/wal.html#performance_considerations)
     */
  public enum Synchronous {
    case normal
    case full
  }
  private static let RebuildIndexDelayOnDiskFull = 5.0  // In seconds..
  private static let RebuildIndexBatchLimit = 500  // We can jam the write queue by just having index rebuild (upon upgrade). This limits that each rebuild batches at this limit, if the limit exceed, we will dispatch back to the queue again to finish up.
  private let filePath: String
  private let fileProtectionLevel: FileProtectionLevel
  private let targetQueue: DispatchQueue
  private let readerPool: SQLiteConnectionPool
  private let synchronous: Synchronous
  private let writeConcurrency: WriteConcurrency
  private var writer: SQLiteConnection?
  private var tableSpaces = [ObjectIdentifier: SQLiteTableSpace]()
  private let state = SQLiteWorkspaceState()
  private let dictionaryStorage = SQLiteWorkspaceDictionary.Storage(namespace: "")
  public var dictionary: WorkspaceDictionary {
    SQLiteWorkspaceDictionary(workspace: self, storage: dictionaryStorage)
  }

  /**
   * Return a SQLite backed Workspace instance.
   *
   * - Parameters:
   *    - filePath: The path to the SQLite file. There will be 3 files named filePath, "\(filePath)-wal" and "\(filePath)-shm" created.
   *    - fileProtectionLevel: The expected protection level for the database file.
   *    - synchronous: The SQLite synchronous mode, read: https://www.sqlite.org/wal.html#performance_considerations
   *    - writeConcurrency: Either `.concurrent` or `.serial`.
   *    - targetQueue: If nil, we will create a queue based on writeConcurrency settings. If you supply your own queue, please read
   *                   about WriteConcurrency before proceed.
   */
  public required init(
    filePath: String, fileProtectionLevel: FileProtectionLevel, synchronous: Synchronous = .normal,
    writeConcurrency: WriteConcurrency = .concurrent, targetQueue: DispatchQueue? = nil
  ) {
    self.filePath = filePath
    self.fileProtectionLevel = fileProtectionLevel
    self.synchronous = synchronous
    self.writeConcurrency = writeConcurrency
    if let targetQueue = targetQueue {
      self.targetQueue = targetQueue
    } else {
      switch writeConcurrency {
      case .concurrent:
        self.targetQueue = DispatchQueue(
          label: "dflat.workq", qos: .default, attributes: .concurrent)
      case .serial:
        self.targetQueue = DispatchQueue(label: "dflat.workq", qos: .default)
      }
    }
    readerPool = SQLiteConnectionPool(capacity: 64, filePath: filePath)
  }

  // MARK - Management

  public func shutdown(completion: (() -> Void)?) {
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else {
      completion?()
      return
    }
    withUnsafeMutablePointer(to: &state.shutdown) {
      UnsafeAtomic(at: $0).store(true, ordering: .releasing)
    }
    var tableSpaces: [SQLiteTableSpace]? = nil
    state.serial {
      tableSpaces = Array(self.tableSpaces.values)
      self.tableSpaces.removeAll()
    }
    let group = DispatchGroup()
    if let tableSpaces = tableSpaces {
      for tableSpace in tableSpaces {
        group.enter()
        tableSpace.queue.async {
          tableSpace.lock()
          tableSpace.shutdown()
          tableSpace.unlock()
          group.leave()
        }
      }
    }
    guard let completion = completion else {
      group.wait()
      return
    }
    group.notify(queue: targetQueue) { [self] in
      // After shutdown all writers, now to drain the reader pool.
      self.readerPool.drain()
      completion()
    }
  }

  // MARK - Mutation

  public func performChanges(
    _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping Workspace.ChangesHandler,
    completionHandler: Workspace.CompletionHandler? = nil
  ) {
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else {
      completionHandler?(false)
      return
    }
    precondition(transactionalObjectTypes.count > 0)
    var transactionalObjectIdentifiers = transactionalObjectTypes.map { ObjectIdentifier($0) }
    transactionalObjectIdentifiers.sort()
    var tableSpaces = [SQLiteTableSpace]()
    state.serial {
      for identifier in transactionalObjectIdentifiers {
        if let tableSpace = self.tableSpaces[identifier] {
          tableSpaces.append(tableSpace)
        } else {
          let tableSpace = self.newTableSpace()
          self.tableSpaces[identifier] = tableSpace
          tableSpaces.append(tableSpace)
        }
      }
    }
    // sync on that particular queue, in this way, we ensures that our operation is done strictly serialize after that one.
    // Without this, if we have thread 1:
    // performChanges([A.self, B.self], ...)
    // performChanges([B.self], ...)
    // because the first line uses A's queue while the second line uses B's queue, there is no guarantee that the
    // changeHandler in the second line will be executed after the first line. It would be surprising and violates strictly
    // serializable guarantee. By using DispatchGroup to enter / leave, we makes sure B's queue will wait for its signal
    // before proceed.
    if tableSpaces.count > 1 {
      let group = DispatchGroup()
      for tableSpace in tableSpaces.suffix(from: 1) {
        // This will suspend these queues upon entering the group.
        tableSpace.enterAndSuspend(group)
      }
      tableSpaces[0].queue.async(
        execute: DispatchWorkItem(flags: .enforceQoS) { [weak self] in
          guard let self = self else {
            completionHandler?(false)
            return
          }
          // It is OK to create connection etc before acquiring the lock as long as we don't do mutation (because we already on its queue, and we only create connection on its own queue).
          guard let connection = tableSpaces[0].connect({ self.newConnection() }) else {
            completionHandler?(false)
            return
          }
          group.wait()  // Force to sync with other queues, and then acquiring locks. The order doesn't matter because at this point, all other queues are suspended.
          for tableSpace in tableSpaces {
            tableSpace.lock()
          }
          // We need to fetch the resultPublisher only after acquired the lock.
          var resultPublishers = [ObjectIdentifier: ResultPublisher]()
          for (i, tableSpace) in tableSpaces.enumerated() {
            resultPublishers[transactionalObjectIdentifiers[i]] = tableSpace.resultPublisher
          }
          let succeed = self.invokeChangesHandler(
            transactionalObjectIdentifiers, connection: connection,
            resultPublishers: resultPublishers, tableState: tableSpaces[0].state,
            changesHandler: changesHandler)
          for tableSpace in tableSpaces.reversed() {
            tableSpace.unlock()
          }
          if tableSpaces.count > 1 {
            // Resume all previous suspended queues.
            for tableSpace in tableSpaces.suffix(from: 1) {
              tableSpace.resume()
            }
          }
          completionHandler?(succeed)
        }
      )
    } else {
      let tableSpace = tableSpaces[0]
      tableSpace.queue.async(
        execute: DispatchWorkItem(flags: .enforceQoS) { [weak self] in
          guard let self = self else {
            completionHandler?(false)
            return
          }
          // It is OK to create connection etc before acquiring the lock as long as we don't do mutation (because we already on its queue, and we only create connection on its own queue).
          guard let connection = tableSpace.connect({ self.newConnection() }) else {
            completionHandler?(false)
            return
          }
          // We need to fetch the resultPublisher only after acquired the lock.
          tableSpace.lock()
          var resultPublishers = [ObjectIdentifier: ResultPublisher]()
          resultPublishers[transactionalObjectIdentifiers[0]] = tableSpace.resultPublisher
          let succeed = self.invokeChangesHandler(
            transactionalObjectIdentifiers, connection: connection,
            resultPublishers: resultPublishers, tableState: tableSpace.state,
            changesHandler: changesHandler)
          tableSpace.unlock()
          completionHandler?(succeed)
        }
      )
    }
  }
  #if compiler(>=5.5) && canImport(_Concurrency)
    /**
   * Perform a transaction for given object types and await either success or failure boolean.
   *
   * - Parameters:
   *    - transactionalObjectTypes: A list of object types you are going to transact with. If you
   *                                If you fetch or mutation an object outside of this list, it will fatal.
   *    - changesHandler: The transaction closure where you will give a transactionContext and safe to do
   *                      data mutations through submission of change requests.
   */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    public func performChanges(
      _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler
    ) async -> Bool {
      return await withUnsafeContinuation { continuation in
        performChanges(transactionalObjectTypes, changesHandler: changesHandler) {
          continuation.resume(returning: $0)
        }
      }
    }
  #endif

  // MARK - Fetching

  class Snapshot {
    private let reader: SQLiteConnectionPool.Borrowed
    let changesTimestamp: Int64
    init(reader: SQLiteConnectionPool.Borrowed, changesTimestamp: Int64) {
      self.reader = reader
      self.changesTimestamp = changesTimestamp
    }
    deinit {
      reader.return()
    }
    func newReader() -> SQLiteConnectionPool.Borrowed {
      return SQLiteConnectionPool.Borrowed(pointee: reader.pointee)
    }
  }

  static private var snapshot: Snapshot? {
    get {
      ThreadLocalStorage.snapshot
    }
    set(newSnapshot) {
      ThreadLocalStorage.snapshot = newSnapshot
    }
  }

  public func fetch<Element: Atom>(for ofType: Element.Type) -> QueryBuilder<Element> {
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else {
      return SQLiteQueryBuilder<Element>(
        reader: SQLiteConnectionPool.Borrowed(pointee: nil, pool: nil), workspace: self,
        transactionContext: nil, changesTimestamp: 0)
    }
    if let txnContext = SQLiteTransactionContext.current {
      precondition(txnContext.contains(ofType: ofType))
      // If we are in a transaction, we cannot have changesTimestamp for fetching. The reason is because this transaction may
      // later abort, causing all changes in this transaction to rollback. We need to refetch all objects fetched in this transaction
      // if we are going to use the changesTimestamp.
      let updatedObjectCount =
        txnContext.objectRepository.updatedObjects[ObjectIdentifier(Element.self)]?.count ?? 0
      // If there is no changes to this particular Element, we are safe to use existing changesTimestamp. Otherwise, we need to use 0.
      let changesTimestamp = updatedObjectCount > 0 ? 0 : txnContext.changesTimestamp
      return SQLiteQueryBuilder<Element>(
        reader: txnContext.borrowed, workspace: self, transactionContext: txnContext,
        changesTimestamp: changesTimestamp)
    }
    if let snapshot = Self.snapshot {
      return SQLiteQueryBuilder<Element>(
        reader: snapshot.newReader(), workspace: self, transactionContext: nil,
        changesTimestamp: snapshot.changesTimestamp)
    }
    let changesTimestamp: Int64 = withUnsafeMutablePointer(to: &state.changesTimestamp) {
      UnsafeAtomic(at: $0).load(ordering: .acquiring)
    }
    return SQLiteQueryBuilder<Element>(
      reader: readerPool.borrow(), workspace: self, transactionContext: nil,
      changesTimestamp: changesTimestamp)
  }

  public func fetchWithinASnapshot<T>(_ closure: () -> T) -> T {
    // If I am in a write transaction, it is a consistent view already.
    if SQLiteTransactionContext.current != nil {
      return closure()
    }
    // Require a consistent snapshot by starting a transaction.
    let reader = readerPool.borrow()
    let changesTimestamp: Int64 = withUnsafeMutablePointer(to: &state.changesTimestamp) {
      UnsafeAtomic(at: $0).load(ordering: .acquiring)
    }
    Self.snapshot = Snapshot(reader: reader, changesTimestamp: changesTimestamp)
    guard let pointee = reader.pointee else {
      let retval = closure()
      Self.snapshot = nil
      return retval
    }
    let begin = pointee.prepareStaticStatement("BEGIN")
    sqlite3_step(begin)
    let retval = closure()
    let commit = pointee.prepareStaticStatement("COMMIT")
    sqlite3_step(commit)
    Self.snapshot = nil
    return retval
  }

  // MARK - Observation

  public func subscribe<Element: Atom>(
    fetchedResult: FetchedResult<Element>,
    changeHandler: @escaping (_: FetchedResult<Element>) -> Void
  ) -> Workspace.Subscription where Element: Equatable {
    let fetchedResult = fetchedResult as! SQLiteFetchedResult<Element>
    let identifier = ObjectIdentifier(fetchedResult.query)
    let subscription = SQLiteSubscription(
      ofType: .fetchedResult(Element.self, identifier), workspace: self)
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else {
      return subscription
    }
    let objectType = ObjectIdentifier(Element.self)
    let tableSpace = self.tableSpace(for: objectType)
    tableSpace.queue.async(
      execute:
        DispatchWorkItem(flags: .enforceQoS) { [weak self] in
          guard let self = self else { return }
          guard let connection = tableSpace.connect({ self.newConnection() }) else { return }
          let objectType = ObjectIdentifier(Element.self)
          let changesTimestamp = self.state.tableTimestamp(for: objectType)
          var fetchedResult = fetchedResult
          // It is OK to create connection etc before acquiring the lock as long as we don't do mutation (because we already on its queue, and we only create connection on its own queue).
          tableSpace.lock()
          defer { tableSpace.unlock() }
          if fetchedResult.changesTimestamp < changesTimestamp {
            let reader = SQLiteConnectionPool.Borrowed(pointee: connection)
            let query = fetchedResult.query
            let limit = fetchedResult.limit
            let orderBy = fetchedResult.orderBy
            var result = [Element]()
            SQLiteQueryWhere(
              reader: reader, workspace: nil, transactionContext: nil,
              changesTimestamp: changesTimestamp, query: query, limit: limit, orderBy: orderBy,
              offset: 0, result: &result)
            let newFetchedResult = SQLiteFetchedResult(
              result, changesTimestamp: changesTimestamp, query: query, limit: limit,
              orderBy: orderBy)
            if newFetchedResult != fetchedResult {
              // If not equal, call changeHandler.
              changeHandler(newFetchedResult)
              // Update this, note that from this point on, ObjectIdentifier(fetchedResult) != resultIdentifier.
              fetchedResult = newFetchedResult
            }
          }
          // The publisher is manipulated after acquiring the lock.
          let resultPublisher: SQLiteResultPublisher<Element>
          if let pub = tableSpace.resultPublisher {
            resultPublisher = pub as! SQLiteResultPublisher<Element>
          } else {
            resultPublisher = SQLiteResultPublisher()
            tableSpace.resultPublisher = resultPublisher
          }
          resultPublisher.subscribe(
            fetchedResult: fetchedResult, resultIdentifier: identifier,
            changeHandler: changeHandler, subscription: subscription)
        }
    )
    return subscription
  }

  public func subscribe<Element: Atom>(
    object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void
  ) -> Workspace.Subscription where Element: Equatable {
    let subscription = SQLiteSubscription(
      ofType: .object(Element.self, object._rowid), workspace: self)
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else {
      return subscription
    }
    let objectType = ObjectIdentifier(Element.self)
    let tableSpace = self.tableSpace(for: objectType)
    tableSpace.queue.async(
      execute:
        DispatchWorkItem(flags: .enforceQoS) { [weak self] in
          guard let self = self else { return }
          guard let connection = tableSpace.connect({ self.newConnection() }) else { return }
          let changesTimestamp = self.state.tableTimestamp(for: objectType)
          // It is OK to create connection etc before acquiring the lock as long as we don't do mutation (because we already on its queue, and we only create connection on its own queue).
          tableSpace.lock()
          defer { tableSpace.unlock() }
          if object._changesTimestamp < changesTimestamp {
            // Since the object is out of date, now we need to check whether we need to call changeHandler immediately.
            let fetchedObject = SQLiteObjectRepository.object(
              connection, ofType: Element.self, for: .rowid(object._rowid))
            guard let updatedObject = fetchedObject else {
              withUnsafeMutablePointer(to: &subscription.cancelled) {
                UnsafeAtomic(at: $0).store(true, ordering: .releasing)
              }
              changeHandler(.deleted)
              return
            }
            if object != updatedObject {  // If object changed, call update.
              updatedObject._changesTimestamp = changesTimestamp
              changeHandler(.updated(updatedObject))
            }
          }
          // The publisher is manipulated after acquiring the lock.
          let resultPublisher: SQLiteResultPublisher<Element>
          if let pub = tableSpace.resultPublisher {
            resultPublisher = pub as! SQLiteResultPublisher<Element>
          } else {
            resultPublisher = SQLiteResultPublisher()
            tableSpace.resultPublisher = resultPublisher
          }
          resultPublisher.subscribe(
            object: object, changeHandler: changeHandler, subscription: subscription)
        }
    )
    return subscription
  }

  func cancel(ofType: SQLiteSubscriptionType, identifier: ObjectIdentifier) {
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else { return }
    switch ofType {
    case let .fetchedResult(atomType, fetchedResult):
      let objectType = ObjectIdentifier(atomType)
      let tableSpace = self.tableSpace(for: objectType)
      // We don't need to prioritize this.
      tableSpace.queue.async {
        tableSpace.lock()
        defer { tableSpace.unlock() }
        // The publisher is manipulated after acquiring the lock.
        guard let resultPublisher = tableSpace.resultPublisher else { return }
        resultPublisher.cancel(fetchedResult: fetchedResult, identifier: identifier)
      }
    case let .object(atomType, rowid):
      let objectType = ObjectIdentifier(atomType)
      let tableSpace = self.tableSpace(for: objectType)
      // We don't need to prioritize this.
      tableSpace.queue.async {
        tableSpace.lock()
        defer { tableSpace.unlock() }
        guard let resultPublisher = tableSpace.resultPublisher else { return }
        resultPublisher.cancel(object: rowid, identifier: identifier)
      }
    }
  }

  // MARK - Combine-compliant

  #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher<Element: Atom>(for object: Element) -> AtomPublisher<Element>
    where Element: Equatable {
      return SQLiteAtomPublisher<Element>(workspace: self, object: object)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher<Element: Atom>(for fetchedResult: FetchedResult<Element>)
      -> FetchedResultPublisher<Element> where Element: Equatable
    {
      return SQLiteFetchedResultPublisher<Element>(workspace: self, fetchedResult: fetchedResult)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func publisher<Element: Atom>(for: Element.Type) -> QueryPublisherBuilder<Element>
    where Element: Equatable {
      return SQLiteQueryPublisherBuilder<Element>(workspace: self)
    }

  #endif

  // MARK - Internal

  static func setUpFilePathWithProtectionLevel(
    filePath: String, fileProtectionLevel: FileProtectionLevel
  ) {
    #if !targetEnvironment(simulator) && (os(iOS) || os(watchOS) || os(tvOS))
      let fd = open_dprotected_np_sb(filePath, O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0)
      close(fd)
      let wal = open_dprotected_np_sb(
        filePath + "-wal", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0)
      close(wal)
      let shm = open_dprotected_np_sb(
        filePath + "-shm", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0)
      close(shm)
    #endif
  }

  // MARK - Concurrency Control Related Methods

  private func tableSpace(for objectType: ObjectIdentifier) -> SQLiteTableSpace {
    let tableSpace: SQLiteTableSpace = state.serial {
      if let tableSpace = tableSpaces[objectType] {
        return tableSpace
      } else {
        let tableSpace = self.newTableSpace()
        tableSpaces[objectType] = tableSpace
        return tableSpace
      }
    }
    return tableSpace
  }

  private func newTableSpace() -> SQLiteTableSpace {
    switch writeConcurrency {
    case .concurrent:
      return ConcurrentSQLiteTableSpace(
        queue: DispatchQueue(label: "dflat.subq", qos: .utility, target: targetQueue))
    case .serial:
      return SerialSQLiteTableSpace(queue: targetQueue)
    }
  }

  private func newConnection() -> SQLiteConnection? {
    dispatchPrecondition(condition: .onQueue(targetQueue))
    switch writeConcurrency {
    case .concurrent:
      // Set the flag before creating the s
      Self.setUpFilePathWithProtectionLevel(
        filePath: filePath, fileProtectionLevel: fileProtectionLevel)
      guard
        let writer = SQLiteConnection(filePath: filePath, createIfMissing: true, readOnly: false)
      else { return nil }
      sqlite3_busy_timeout(writer.sqlite, 30_000)
      sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
      switch synchronous {
      case .normal:
        sqlite3_exec(writer.sqlite, "PRAGMA synchronous=NORMAL", nil, nil, nil)
      case .full:
        sqlite3_exec(writer.sqlite, "PRAGMA synchronous=FULL", nil, nil, nil)
      }
      sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
      sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
      return writer
    case .serial:
      guard self.writer == nil else { return self.writer }
      // Set the flag before creating the s
      Self.setUpFilePathWithProtectionLevel(
        filePath: filePath, fileProtectionLevel: fileProtectionLevel)
      guard
        let writer = SQLiteConnection(filePath: filePath, createIfMissing: true, readOnly: false)
      else { return nil }
      sqlite3_busy_timeout(writer.sqlite, 30_000)
      sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
      switch synchronous {
      case .normal:
        sqlite3_exec(writer.sqlite, "PRAGMA synchronous=NORMAL", nil, nil, nil)
      case .full:
        sqlite3_exec(writer.sqlite, "PRAGMA synchronous=FULL", nil, nil, nil)
      }
      sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
      sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
      self.writer = writer
      return writer
    }
  }

  private func invokeChangesHandler(
    _ transactionalObjectTypes: [ObjectIdentifier], connection: SQLiteConnection,
    resultPublishers: [ObjectIdentifier: ResultPublisher], tableState: SQLiteTableState,
    changesHandler: Workspace.ChangesHandler
  ) -> Bool {
    let oldChangesTimestamp: Int64 = withUnsafeMutablePointer(to: &state.changesTimestamp) {
      UnsafeAtomic(at: $0).load(ordering: .acquiring)
    }
    let txnContext = SQLiteTransactionContext(
      state: tableState, objectTypes: transactionalObjectTypes,
      changesTimestamp: oldChangesTimestamp, connection: connection)
    changesHandler(txnContext)
    let updatedObjects = txnContext.objectRepository.updatedObjects
    txnContext.destroy()
    // This transaction is aborted by user. rollback.
    if txnContext.aborted {
      if txnContext.began {  // If it doesn't even begin a transaction, no need to rollback.
        let rollback = connection.prepareStaticStatement("ROLLBACK")
        let status = sqlite3_step(rollback)
        precondition(status == SQLITE_DONE)
      }
      return false
    }
    // If we started a transaction, because we called submit. Commit now.
    if txnContext.began {
      let commit = connection.prepareStaticStatement("COMMIT")
      let status = sqlite3_step(commit)
      if SQLITE_FULL == status {
        let rollback = connection.prepareStaticStatement("ROLLBACK")
        let status = sqlite3_step(rollback)
        precondition(status == SQLITE_DONE)
        return false
      }
      precondition(status == SQLITE_DONE)
    }
    var reader: SQLiteConnectionPool.Borrowed? = nil
    let newChangesTimestamp =
      (withUnsafeMutablePointer(to: &state.changesTimestamp) {
        UnsafeAtomic(at: $0).loadThenWrappingIncrement(by: 1, ordering: .releasing)
      }) + 1  // Return the previously hold timestamp, thus, the new timestamp need + 1
    state.setTableTimestamp(newChangesTimestamp, for: updatedObjects.keys)
    for (identifier, updates) in updatedObjects {
      guard let resultPublisher = resultPublishers[identifier] else { continue }
      if reader == nil {
        reader = SQLiteConnectionPool.Borrowed(pointee: connection)
      }
      guard let reader = reader else { continue }
      resultPublisher.publishUpdates(updates, reader: reader, changesTimestamp: newChangesTimestamp)
    }
    return true
  }
}

// MARK - Build Index

extension SQLiteWorkspace {

  func buildIndex<Element: Atom>(
    _ ofType: Element.Type, field: String, toolbox: SQLitePersistenceToolbox, limit: Int
  ) -> (insertedRows: Int, done: Bool) {
    dispatchPrecondition(condition: .onQueue(targetQueue))
    guard let sqlite = toolbox.connection.sqlite else { return (0, false) }
    let SQLiteElement = Element.self as! SQLiteAtom.Type
    var _query: OpaquePointer? = nil
    guard
      SQLITE_OK
        == sqlite3_prepare_v2(
          sqlite,
          "SELECT rowid,p FROM \(SQLiteElement.table) WHERE rowid > IFNULL((SELECT MAX(rowid) FROM \(SQLiteElement.table)__\(field)),0)",
          -1, &_query, nil)
    else { return (0, false) }
    guard let query = _query else { return (0, false) }
    var insertedRows = 0
    var done = true
    while SQLITE_ROW == sqlite3_step(query) {
      let blob = sqlite3_column_blob(query, 1)
      let blobSize = sqlite3_column_bytes(query, 1)
      let rowid = sqlite3_column_int64(query, 0)
      let bb = ByteBuffer(
        assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
      if SQLiteElement.insertIndex(toolbox, field: field, rowid: rowid, table: bb) {
        insertedRows += 1
        if insertedRows >= limit {
          done = false
          break
        }
      } else {
        // TODO: Handle unique constraint violation: SQLITE_CONSTRAINT_UNIQUE
      }
    }
    sqlite3_finalize(query)
    return (insertedRows, done)
  }

  func beginRebuildIndex<Element: Atom, S: Sequence>(_ ofType: Element.Type, fields: S)
  where S.Element == String {
    guard
      !(withUnsafeMutablePointer(to: &state.shutdown) {
        UnsafeAtomic(at: $0).load(ordering: .acquiring)
      })
    else { return }
    let objectType = ObjectIdentifier(Element.self)
    let tableSpace = self.tableSpace(for: objectType)
    // We don't need to bump the priority for this.
    tableSpace.queue.async { [weak self] in
      guard let self = self else { return }
      guard let connection = tableSpace.connect({ self.newConnection() }) else { return }
      let SQLiteElement = Element.self as! SQLiteAtom.Type
      let toolbox = SQLitePersistenceToolbox(connection: connection)
      let table = SQLiteElement.table
      // It is OK to create connection, etc. before acquiring the lock as long as we don't do mutation.
      tableSpace.lock()
      defer { tableSpace.unlock() }
      // Make sure the table exists before we query.
      if !tableSpace.state.tableCreated.contains(objectType) {
        SQLiteElement.setUpSchema(toolbox)
        tableSpace.state.tableCreated.insert(objectType)
      }
      let indexSurvey = connection.indexSurvey(fields, table: table)
      // Obtain a exclusive lock, see discussions in SQLiteTransactionContext for why.
      let begin = connection.prepareStaticStatement("BEGIN IMMEDIATE")
      // If we cannot start a transaction, nothing we can do, just wait for re-trigger.
      guard SQLITE_DONE == sqlite3_step(begin) else { return }
      // We may still have "unavailable" due to other issues (for example, disk full). Ignore for now
      // and will re-trigger this on later queries.
      var limit = Self.RebuildIndexBatchLimit
      var newFields = indexSurvey.partial
      for field in indexSurvey.partial {
        let retval = self.buildIndex(Element.self, field: field, toolbox: toolbox, limit: limit)
        limit -= retval.insertedRows
        if retval.done {
          newFields.remove(field)
        }
        if limit <= 0 {
          break
        }
      }
      // Try to commit.
      let commit = connection.prepareStaticStatement("COMMIT")
      let status = sqlite3_step(commit)
      if SQLITE_FULL == status {
        let rollback = connection.prepareStaticStatement("ROLLBACK")
        let status = sqlite3_step(rollback)
        precondition(status == SQLITE_DONE)
        // In case we failed, trigger a redo a few seconds later.
        tableSpace.queue.asyncAfter(deadline: .now() + Self.RebuildIndexDelayOnDiskFull) {
          [weak self] in
          self?.beginRebuildIndex(Element.self, fields: fields)
        }
        return
      }
      connection.clearIndexStatus(for: table)
      if newFields.count > 0 {
        // Re-enqueue to process the remaining indexes.
        self.beginRebuildIndex(Element.self, fields: newFields)
      }
    }
  }

}
