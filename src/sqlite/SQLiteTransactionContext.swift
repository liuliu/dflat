import Dflat
import SQLite3
import Foundation

// This is the object per transaction. Even if we support multi-writer later, we will simply
// have one TransactionContext per writer. No thread-safety concerns.
public final class SQLiteTransactionContext: TransactionContext {
  public var objectRepository = SQLiteObjectRepository()
  public var connection: SQLiteConnection {
    toolbox.connection
  }
  private let objectTypes: Set<ObjectIdentifier>
  private let state: SQLiteTableState
  private let toolbox: SQLitePersistenceToolbox
  private var tableCreated = Set<ObjectIdentifier>()
  var borrowed: SQLiteConnectionPool.Borrowed {
    SQLiteConnectionPool.Borrowed(pointee: toolbox.connection)
  }
  var aborted: Bool = false
  
  static private(set) public var current: SQLiteTransactionContext? {
    get {
      Thread.current.threadDictionary["SQLiteTxnCurrent"] as? SQLiteTransactionContext
    }
    set (newCurrent) {
      Thread.current.threadDictionary["SQLiteTxnCurrent"] = newCurrent
    }
  }

  init(state: SQLiteTableState, objectTypes: [Any.Type], writer: SQLiteConnection) {
    var objectTypesSet = Set<ObjectIdentifier>()
    for type in objectTypes {
      objectTypesSet.update(with: ObjectIdentifier(type))
    }
    self.state = state
    self.objectTypes = objectTypesSet
    self.toolbox = SQLitePersistenceToolbox(connection: writer)
    Self.current = self
  }

  func destroy() {
    Self.current = nil
  }

  func contains(ofType: Any.Type) -> Bool {
    return objectTypes.contains(ObjectIdentifier(ofType))
  }
  
  static func transactionalUpdate(toolbox: SQLitePersistenceToolbox, updater: (_: SQLitePersistenceToolbox) -> UpdatedObject?) -> UpdatedObject? {
    let savepoint = toolbox.connection.prepareStatement("SAVEPOINT dflat_txn")
    guard SQLITE_DONE == sqlite3_step(savepoint) else { return nil }
    let updatedObject = updater(toolbox)
    guard updatedObject != nil else {
      let rollback = toolbox.connection.prepareStatement("ROLLBACK TO dflat_txn")
      // We cannot handle the situation where the rollback failed.
      let status = sqlite3_step(rollback)
      assert(status == SQLITE_DONE)
      return nil
    }
    let release = toolbox.connection.prepareStatement("RELEASE dflat_txn")
    let status = sqlite3_step(release)
    if status == SQLITE_FULL {
      // In case of disk full, rollback.
      let rollback = toolbox.connection.prepareStatement("ROLLBACK TO dflat_txn")
      let status = sqlite3_step(rollback)
      assert(status == SQLITE_DONE)
      return nil
    }
    assert(status == SQLITE_DONE)
    return updatedObject
  }

  @discardableResult
  public func submit(_ changeRequest: ChangeRequest) -> Bool {
    let atomType = type(of: changeRequest).atomType
    precondition(contains(ofType: atomType))
    guard !aborted else { return false }
    let atomTypeIdentifier = ObjectIdentifier(atomType)
    if !state.tableCreated.contains(atomTypeIdentifier) {
      type(of: changeRequest).setUpSchema(toolbox)
      state.tableCreated.insert(atomTypeIdentifier)
      tableCreated.insert(atomTypeIdentifier)
    }
    let retval = Self.transactionalUpdate(toolbox: toolbox) { toolbox in
      changeRequest.commit(toolbox)
    }
    guard let updatedObject = retval else { return false }
    objectRepository.set(updatedObject: updatedObject, ofTypeIdentifier: atomTypeIdentifier)
    return true
  }

  @discardableResult
  public func abort() -> Bool {
    guard !aborted else { return false }
    aborted = true
    state.tableCreated.subtract(tableCreated)
    return true
  }
}
