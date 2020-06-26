import Dflat
import SQLite3
import Dispatch
import Foundation
import FlatBuffers
import SQLiteDflatObjC

public final class SQLiteWorkspace: Workspace {

  public enum FileProtectionLevel: Int32 {
    case noProtection = 4 // Class D
    case completeFileProtection = 1 // Class A
    case completeFileProtectionUnlessOpen = 2 // Class B
    case completeFileProtectionUntilFirstUserAuthentication = 3 // Class C
  }
  public enum WriteConcurrency {
    case concurrent
    case serial
  }
  private static let RebuildIndexDelayOnDiskFull = 5.0 // In seconds..
  private static let RebuildIndexBatchLimit = 500 // We can jam the write queue by just having index rebuild (upon upgrade). This limits that each rebuild batches at this limit, if the limit exceed, we will dispatch back to the queue again to finish up.
  private let filePath: String
  private let fileProtectionLevel: FileProtectionLevel
  private let targetQueue: DispatchQueue
  private let readerPool: SQLiteConnectionPool
  private let writeConcurrency: WriteConcurrency
  private var writer: SQLiteConnection?
  private var tableSpaces = [ObjectIdentifier: SQLiteTableSpace]()
  private let state = SQLiteWorkspaceState()

  public required init(filePath: String, fileProtectionLevel: FileProtectionLevel, writeConcurrency: WriteConcurrency = .concurrent, targetQueue: DispatchQueue = DispatchQueue(label: "dflat.workq", qos: .utility, attributes: .concurrent)) {
    self.filePath = filePath
    self.fileProtectionLevel = fileProtectionLevel
    self.writeConcurrency = writeConcurrency
    self.targetQueue = targetQueue
    self.readerPool = SQLiteConnectionPool(capacity: 64, filePath: filePath)
  }

  // MARK - Mutation

  public func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping Workspace.ChangesHandler, completionHandler: Workspace.CompletionHandler? = nil) {
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
    tableSpaces[0].queue.async(execute:
      DispatchWorkItem(flags: .enforceQoS) { [weak self] in
        guard let self = self else { return }
        guard let connection = tableSpaces[0].connect({ self.newConnection() }) else {
          completionHandler?(false)
          return
        }
        // It is OK to create connection etc before acquiring the lock as long as we don't do mutation (because we already on its queue, and we only create connection on its own queue).
        for tableSpace in tableSpaces {
          tableSpace.lock()
        }
        // We need to fetch the resultPublisher only after acquired the lock.
        var resultPublishers = [ObjectIdentifier: ResultPublisher]()
        for (i, tableSpace) in tableSpaces.enumerated() {
          resultPublishers[transactionalObjectIdentifiers[i]] = tableSpace.resultPublisher
        }
        let succeed = self.invokeChangesHandler(transactionalObjectIdentifiers, connection: connection, resultPublishers: resultPublishers, tableState: tableSpaces[0].state, changesHandler: changesHandler)
        for tableSpace in tableSpaces.reversed() {
          tableSpace.unlock()
        }
        completionHandler?(succeed)
      }
    )
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
      // If we are in a transaction, we cannot have changesTimestamp for fetching. The reason is because this transaction may
      // later abort, causing all changes in this transaction to rollback. We need to refetch all objects fetched in this transaction
      // if we are going to use the changesTimestamp.
      let updatedObjectCount = txnContext.objectRepository.updatedObjects[ObjectIdentifier(Element.self)]?.count ?? 0
      // If there is no changes to this particular Element, we are safe to use existing changesTimestamp. Otherwise, we need to use 0.
      let changesTimestamp = updatedObjectCount > 0 ? 0 : txnContext.changesTimestamp
      return SQLiteQueryBuilder<Element>(reader: txnContext.borrowed, workspace: self, transactionContext: txnContext, changesTimestamp: changesTimestamp)
    }
    if let snapshot = Self.snapshot {
      return SQLiteQueryBuilder<Element>(reader: snapshot.reader, workspace: self, transactionContext: nil, changesTimestamp: snapshot.changesTimestamp)
    }
    let changesTimestamp = state.changesTimestamp.load(order: .acquire)
    return SQLiteQueryBuilder<Element>(reader: readerPool.borrow(), workspace: self, transactionContext: nil, changesTimestamp: changesTimestamp)
  }
  
  public func fetchWithinASnapshot<T>(_ closure: () -> T) -> T {
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
    let commit = pointee.prepareStatement("COMMIT")
    sqlite3_step(commit)
    Self.snapshot = nil
    return retval
  }

  // MARK - Observation

  public func subscribe<Element: Atom>(fetchedResult: FetchedResult<Element>, changeHandler: @escaping (_: FetchedResult<Element>) -> Void) -> Workspace.Subscription where Element: Equatable {
    let identifier = ObjectIdentifier(fetchedResult)
    let subscription = SQLiteSubscription(ofType: .fetchedResult(Element.self, identifier), identifier: ObjectIdentifier(changeHandler as AnyObject), workspace: self)
    let fetchedResult = fetchedResult as! SQLiteFetchedResult<Element>
    let objectType = ObjectIdentifier(Element.self)
    let tableSpace = self.tableSpace(for: objectType)
    tableSpace.queue.async(execute:
      DispatchWorkItem(flags: .enforceQoS) { [weak self] in
        guard let self = self else { return }
        guard let connection = tableSpace.connect({ self.newConnection() }) else { return }
        let identifier = ObjectIdentifier(Element.self)
        let changesTimestamp = self.state.tableTimestamp(for: identifier)
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
          SQLiteQueryWhere(reader: reader, workspace: nil, transactionContext: nil, changesTimestamp: changesTimestamp, query: query, limit: limit, orderBy: orderBy, offset: 0, result: &result)
          let newFetchedResult = SQLiteFetchedResult(result, changesTimestamp: changesTimestamp, query: query, limit: limit, orderBy: orderBy)
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
        resultPublisher.subscribe(fetchedResult: fetchedResult, resultIdentifier: identifier, changeHandler: changeHandler, subscription: subscription)
      }
    )
    return subscription
  }

  public func subscribe<Element: Atom>(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void) -> Workspace.Subscription where Element: Equatable {
    let subscription = SQLiteSubscription(ofType: .object(Element.self, object._rowid), identifier: ObjectIdentifier(changeHandler as AnyObject), workspace: self)
    let objectType = ObjectIdentifier(Element.self)
    let tableSpace = self.tableSpace(for: objectType)
    tableSpace.queue.async(execute:
      DispatchWorkItem(flags: .enforceQoS) { [weak self] in
        guard let self = self else { return }
        guard let connection = tableSpace.connect({ self.newConnection() }) else { return }
        let changesTimestamp = self.state.tableTimestamp(for: objectType)
        // It is OK to create connection etc before acquiring the lock as long as we don't do mutation (because we already on its queue, and we only create connection on its own queue).
        tableSpace.lock()
        defer { tableSpace.unlock() }
        if object._changesTimestamp < changesTimestamp {
          // Since the object is out of date, now we need to check whether we need to call changeHandler immediately.
          let fetchedObject = SQLiteObjectRepository.object(connection, ofType: Element.self, for: .rowid(object._rowid))
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
        // The publisher is manipulated after acquiring the lock.
        let resultPublisher: SQLiteResultPublisher<Element>
        if let pub = tableSpace.resultPublisher {
          resultPublisher = pub as! SQLiteResultPublisher<Element>
        } else {
          resultPublisher = SQLiteResultPublisher()
          tableSpace.resultPublisher = resultPublisher
        }
        resultPublisher.subscribe(object: object, changeHandler: changeHandler, subscription: subscription)
      }
    )
    return subscription
  }
  
  func cancel(ofType: SQLiteSubscriptionType, identifier: ObjectIdentifier) {
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

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  public func publisher<Element: Atom>(for object: Element) -> AtomPublisher<Element> where Element: Equatable {
    return SQLiteAtomPublisher<Element>(workspace: self, object: object)
  }

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  public func publisher<Element: Atom>(for fetchedResult: FetchedResult<Element>) -> FetchedResultPublisher<Element> where Element: Equatable {
    return SQLiteFetchedResultPublisher<Element>(workspace: self, fetchedResult: fetchedResult)
  }

  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  public func publisher<Element: Atom>(for: Element.Type) -> QueryPublisherBuilder<Element> where Element: Equatable {
    return SQLiteQueryPublisherBuilder<Element>(workspace: self)
  }

  // MARK - Internal

  static func setUpFilePathWithProtectionLevel(filePath: String, fileProtectionLevel: FileProtectionLevel) {
    #if !targetEnvironment(simulator)
    let fd = open_dprotected_np_sb(filePath, O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0)
    close(fd)
    let wal = open_dprotected_np_sb(filePath + "-wal", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0)
    close(wal)
    let shm = open_dprotected_np_sb(filePath + "-shm", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0)
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
      return ConcurrentSQLiteTableSpace(queue: DispatchQueue(label: "dflat.subq", target: targetQueue))
    case .serial:
      return SerialSQLiteTableSpace(queue: targetQueue)
    }
  }
  
  private func newConnection() -> SQLiteConnection? {
    dispatchPrecondition(condition: .onQueue(targetQueue))
    switch writeConcurrency {
    case .concurrent:
      // Set the flag before creating the s
      Self.setUpFilePathWithProtectionLevel(filePath: filePath, fileProtectionLevel: fileProtectionLevel)
      guard let writer = SQLiteConnection(filePath: filePath, createIfMissing: true) else { return nil }
      sqlite3_busy_timeout(writer.sqlite, 10_000)
      sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
      sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
      sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
      return writer
    case .serial:
      guard self.writer == nil else { return self.writer }
      // Set the flag before creating the s
      Self.setUpFilePathWithProtectionLevel(filePath: filePath, fileProtectionLevel: fileProtectionLevel)
      guard let writer = SQLiteConnection(filePath: filePath, createIfMissing: true) else { return nil }
      sqlite3_busy_timeout(writer.sqlite, 10_000)
      sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
      sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
      sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
      self.writer = writer
      return writer
    }
  }

  private func invokeChangesHandler(_ transactionalObjectTypes: [ObjectIdentifier], connection: SQLiteConnection, resultPublishers: [ObjectIdentifier: ResultPublisher], tableState: SQLiteTableState, changesHandler: Workspace.ChangesHandler) -> Bool {
    let txnContext = SQLiteTransactionContext(state: tableState, objectTypes: transactionalObjectTypes, changesTimestamp: state.changesTimestamp.load(), connection: connection)
    let begin = connection.prepareStatement("BEGIN")
    guard SQLITE_DONE == sqlite3_step(begin) else {
      return false
    }
    changesHandler(txnContext)
    let updatedObjects = txnContext.objectRepository.updatedObjects
    txnContext.destroy()
    // This transaction is aborted by user. rollback.
    if txnContext.aborted {
      let rollback = connection.prepareStatement("ROLLBACK")
      let status = sqlite3_step(rollback)
      precondition(status == SQLITE_DONE)
      return false
    }
    let commit = connection.prepareStatement("COMMIT")
    let status = sqlite3_step(commit)
    if SQLITE_FULL == status {
      let rollback = connection.prepareStatement("ROLLBACK")
      let status = sqlite3_step(rollback)
      precondition(status == SQLITE_DONE)
      return false
    }
    precondition(status == SQLITE_DONE)
    var reader: SQLiteConnectionPool.Borrowed? = nil
    let newChangesTimestamp = state.changesTimestamp.increment(order: .release) + 1 // Return the previously hold timestamp, thus, the new timestamp need + 1
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

  func buildIndex<Element: Atom>(_ ofType: Element.Type, field: String, toolbox: SQLitePersistenceToolbox, limit: Int) -> (insertedRows: Int, done: Bool) {
    dispatchPrecondition(condition: .onQueue(targetQueue))
    guard let sqlite = toolbox.connection.sqlite else { return (0, false) }
    let SQLiteElement = Element.self as! SQLiteAtom.Type
    var _query: OpaquePointer? = nil
    guard SQLITE_OK == sqlite3_prepare_v2(sqlite, "SELECT rowid,p FROM \(SQLiteElement.table) WHERE rowid > IFNULL((SELECT MAX(rowid) FROM \(SQLiteElement.table)__\(field)),0)", -1, &_query, nil) else { return (0, false) }
    guard let query = _query else { return (0, false) }
    var insertedRows = 0
    var done = true
    while SQLITE_ROW == sqlite3_step(query) {
      let blob = sqlite3_column_blob(query, 1)
      let blobSize = sqlite3_column_bytes(query, 1)
      let rowid = sqlite3_column_int64(query, 0)
      let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: blob!), capacity: Int(blobSize))
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

  func beginRebuildIndex<Element: Atom, S: Sequence>(_ ofType: Element.Type, fields: S) where S.Element == String {
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
      let begin = connection.prepareStatement("BEGIN")
      // If we cannot start a transaction, nothing we can do, just wait for re-trigger.
      guard SQLITE_DONE == sqlite3_step(begin) else { return }
      // Make sure the table exists before we query.
      if !tableSpace.state.tableCreated.contains(objectType) {
        SQLiteElement.setUpSchema(toolbox)
        tableSpace.state.tableCreated.insert(objectType)
      }
      let indexSurvey = connection.indexSurvey(fields, table: table)
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
      let commit = connection.prepareStatement("COMMIT")
      let status = sqlite3_step(commit)
      if SQLITE_FULL == status {
        let rollback = connection.prepareStatement("ROLLBACK")
        let status = sqlite3_step(rollback)
        precondition(status == SQLITE_DONE)
        // In case we failed, trigger a redo a few seconds later.
        tableSpace.queue.asyncAfter(deadline: .now() + Self.RebuildIndexDelayOnDiskFull) { [weak self] in
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
