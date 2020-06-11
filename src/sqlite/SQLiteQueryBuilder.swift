import Dflat

func SQLiteQueryWhere<Element: Atom>(reader: SQLiteConnectionPool.Borrowed, clause: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy], result: inout [Element]) {
  var statement = ""
  var parameterCount: Int32 = 0
  clause.buildWhereClause(availableIndexes: Set(), clause: &statement, parameterCount: &parameterCount)
  parameterCount = 0
  // clause.bindWhereClause(availableIndexes: Set(), clause: preparedQuery, parameterCount: &parameterCount)
}

final class SQLiteQueryBuilder<Element: Atom>: QueryBuilder<Element> {
  private let reader: SQLiteConnectionPool.Borrowed
  public init(_ reader: SQLiteConnectionPool.Borrowed) {
    self.reader = reader
    super.init()
  }
  override func `where`<T: Expr>(_ clause: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> where T.ResultType == Bool {
    let sqlClause = AnySQLiteExpr(clause, clause as! SQLiteExpr)
    var result = [Element]()
    SQLiteQueryWhere(reader: reader, clause: sqlClause, limit: limit, orderBy: orderBy, result: &result)
    return SQLiteFetchedResult(result, clause: sqlClause, limit: limit, orderBy: orderBy)
  }
}
