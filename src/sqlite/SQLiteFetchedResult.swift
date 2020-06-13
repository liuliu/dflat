import Dflat

final class SQLiteFetchedResult<Element: Atom>: FetchedResult<Element> {
  private let query: AnySQLiteExpr<Bool>
  private let limit: Limit
  private let orderBy: [OrderBy]

  init(_ array: [Element], query: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy]) {
    self.query = query
    self.limit = limit
    self.orderBy = orderBy
    super.init(array)
  }

}
