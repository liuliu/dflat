import Dflat

extension GreaterThanExpr: SQLiteExpr where L: SQLiteExpr, R: SQLiteExpr {
  public func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(indexSurvey) == .full else { return }
    query.append("(")
    left.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
    query.append(") > (")
    right.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
    query.append(")")
  }
  public func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(indexSurvey) == .full else { return }
    left.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
    right.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
  }
}
