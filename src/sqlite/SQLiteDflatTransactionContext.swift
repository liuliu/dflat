import Dflat

struct SQLiteDflatTransactionContext: DflatTransactionContext {
  private let writer: SQLiteConnection
  func submit(_: DflatChangeRequest) -> Bool {
    return true
  }
}
