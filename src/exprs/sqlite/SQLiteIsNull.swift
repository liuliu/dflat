extension IsNullExpr: SQLiteExpr where T: SQLiteExpr {
  public func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(indexSurvey) == .full else { return }
    query.append("(")
    unary.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
    query.append(") ISNULL")
  }
  public func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(indexSurvey) == .full else { return }
    unary.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
  }
}
