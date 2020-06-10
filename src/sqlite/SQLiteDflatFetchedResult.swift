import Dflat

final class SQLiteDflatFetchedResult<Element: DflatAtom>: DflatFetchedResult<Element> {
  private let clause: AnySQLiteExpr<Bool>
  private let limit: Limit
  private let orderBy: [OrderBy]

  init(_ array: [Element], clause: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy]) {
    self.clause = clause
    self.limit = limit
    self.orderBy = orderBy
    super.init(array)
  }

}
