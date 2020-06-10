import Dflat

func SQLiteQueryWhere<Element: DflatAtom>(reader: SQLiteConnectionPool.Borrowed, clause: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy], result: inout [Element]) {
  var statement = ""
  var parameterCount: Int32 = 0
  clause.buildWhereClause(availableIndexes: Set(), clause: &statement, parameterCount: &parameterCount)
  parameterCount = 0
  // clause.bindWhereClause(availableIndexes: Set(), clause: preparedQuery, parameterCount: &parameterCount)
}

final class SQLiteDflatQueryBuilder<Element: DflatAtom>: DflatQueryBuilder<Element> {
  private let reader: SQLiteConnectionPool.Borrowed
  public init(_ reader: SQLiteConnectionPool.Borrowed) {
    self.reader = reader
    super.init()
  }
  override func `where`<T: Expr>(_ clause: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> DflatFetchedResult<Element> where T.ResultType == Bool {
    let sqlClause = AnySQLiteExpr(clause, clause as! SQLiteExpr)
    var result = [Element]()
    SQLiteQueryWhere(reader: reader, clause: sqlClause, limit: limit, orderBy: orderBy, result: &result)
    return SQLiteDflatFetchedResult(result, clause: sqlClause, limit: limit, orderBy: orderBy)
  }
}
