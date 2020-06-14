import Dflat

final class SQLiteFetchedResult<Element: Atom>: FetchedResult<Element> {
  let changesTimestamp: Int64
  private let query: AnySQLiteExpr<Bool>
  private let limit: Limit
  private let orderBy: [OrderBy]

  init(_ array: [Element], changesTimestamp: Int64, query: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy]) {
    self.changesTimestamp = changesTimestamp
    self.query = query
    self.limit = limit
    self.orderBy = orderBy
    super.init(array)
  }

}
