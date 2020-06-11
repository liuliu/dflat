import Dflat
import SQLite3

final class SQLiteTransactionContext: TransactionContext {
  private let writer: SQLiteConnection
  private let anyPool: Set<ObjectIdentifier>

  init(anyPool: [Any.Type], writer: SQLiteConnection) {
    self.writer = writer
    var anySet = Set<ObjectIdentifier>()
    for type in anyPool {
      anySet.update(with: ObjectIdentifier(type))
    }
    self.anyPool = anySet
  }

  @discardableResult
  func submit(_ changeRequest: ChangeRequest) -> Bool {
    precondition(anyPool.contains(ObjectIdentifier(type(of: changeRequest).atomType)))
    let savepoint = writer.prepareStatement("SAVEPOINT dlfat_txn")
    sqlite3_step(savepoint)
    let rollback = writer.prepareStatement("ROLLBACK TO dflat_txn")
    sqlite3_step(rollback)
    let release = writer.prepareStatement("RELEASE dflat_txn")
    sqlite3_step(release)
    return true
  }

  @discardableResult
  func abort() -> Bool {
    return true
  }
}
