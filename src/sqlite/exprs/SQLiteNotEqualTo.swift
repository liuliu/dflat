import Dflat

extension NotEqualToExpr: SQLiteExpr where L: SQLiteExpr, R: SQLiteExpr {
  public func buildWhereQuery(availableIndexes: Set<String>, query: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    query.append("(")
    left.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
    query.append(") != (")
    right.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
    query.append(")")
  }
  public func bindWhereQuery(availableIndexes: Set<String>, query: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    left.bindWhereQuery(availableIndexes: availableIndexes, query: query, parameterCount: &parameterCount)
    right.bindWhereQuery(availableIndexes: availableIndexes, query: query, parameterCount: &parameterCount)
  }
}
