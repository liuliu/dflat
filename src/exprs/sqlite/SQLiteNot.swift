extension NotExpr: SQLiteExpr where T: SQLiteExpr {
  @inlinable
  public func buildWhereQuery(
    indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32
  ) {
    guard self.canUsePartialIndex(indexSurvey) == .full else { return }
    query.append("NOT (")
    unary.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
    query.append(")")
  }
  @inlinable
  public func bindWhereQuery(
    indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32
  ) {
    guard self.canUsePartialIndex(indexSurvey) == .full else { return }
    unary.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
    // TODO:
  }
}
