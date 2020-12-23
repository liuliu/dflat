import Dflat

final class SQLiteFetchedResult<Element: Atom>: FetchedResult<Element> {
  let changesTimestamp: Int64
  let query: AnySQLiteExpr<Bool, Element>
  let limit: Limit
  let orderBy: [OrderBy<Element>]

  init(
    _ array: [Element], changesTimestamp: Int64, query: AnySQLiteExpr<Bool, Element>, limit: Limit,
    orderBy: [OrderBy<Element>]
  ) {
    self.changesTimestamp = changesTimestamp
    self.query = query
    self.limit = limit
    self.orderBy = orderBy
    super.init(array)
  }
}
