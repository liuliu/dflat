import Dflat

extension IsNotNullExpr: SQLiteExpr where T: SQLiteExpr {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    clause.append("(")
    unary.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    clause.append(") IS NOT NULL")
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    unary.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
  }
}
