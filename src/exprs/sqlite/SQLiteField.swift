extension FieldExpr: SQLiteExpr {
  @inlinable
  public func buildWhereQuery(
    indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32
  ) {
    guard self.canUsePartialIndex(indexSurvey) != .none else { return }
    query.append(self.name)
  }
  @inlinable
  public func bindWhereQuery(
    indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32
  ) {}
}
