import Dflat
import SQLite3
import Foundation

final class SQLiteTransactionContext: TransactionContext {
  private let anyPool: Set<ObjectIdentifier>
  private let toolbox: SQLitePersistenceToolbox
  var borrowed: SQLiteConnectionPool.Borrowed {
    SQLiteConnectionPool.Borrowed(toolbox.connection)
  }
  
  static private(set) var current: SQLiteTransactionContext? {
    get {
      Thread.current.threadDictionary["SQLiteTxnCurrent"] as? SQLiteTransactionContext
    }
    set (newCurrent) {
      Thread.current.threadDictionary["SQLiteTxnCurrent"] = newCurrent
    }
  }

  init(anyPool: [Any.Type], writer: SQLiteConnection) {
    var anySet = Set<ObjectIdentifier>()
    for type in anyPool {
      anySet.update(with: ObjectIdentifier(type))
    }
    self.anyPool = anySet
    self.toolbox = SQLitePersistenceToolbox(connection: writer)
    Self.current = self
  }

  func destroy() {
    Self.current = nil
  }

  func contains(ofType: Any.Type) -> Bool {
    return anyPool.contains(ObjectIdentifier(ofType))
  }
  
  static func transactionalUpdate(toolbox: SQLitePersistenceToolbox, updater: (_: SQLitePersistenceToolbox) -> Bool) -> Bool {
    let savepoint = toolbox.connection.prepareStatement("SAVEPOINT dflat_txn")
    guard SQLITE_DONE == sqlite3_step(savepoint) else { return false }
    let success = updater(toolbox)
    guard success else {
      let rollback = toolbox.connection.prepareStatement("ROLLBACK TO dflat_txn")
      // We cannot handle the situation where the rollback failed.
      let status = sqlite3_step(rollback)
      assert(status == SQLITE_DONE)
      return false
    }
    let release = toolbox.connection.prepareStatement("RELEASE dflat_txn")
    let status = sqlite3_step(release)
    if status == SQLITE_FULL {
      // In case of disk full, rollback.
      let rollback = toolbox.connection.prepareStatement("ROLLBACK TO dflat_txn")
      let status = sqlite3_step(rollback)
      assert(status == SQLITE_DONE)
      return false
    }
    assert(status == SQLITE_DONE)
    return false
  }

  @discardableResult
  func submit(_ changeRequest: ChangeRequest) -> Bool {
    precondition(contains(ofType: type(of: changeRequest).atomType))
    type(of: changeRequest).setUpSchema(toolbox)
    return Self.transactionalUpdate(toolbox: toolbox) { toolbox in
      changeRequest.commit(toolbox)
    }
  }

  @discardableResult
  func abort() -> Bool {
    return true
  }
}
