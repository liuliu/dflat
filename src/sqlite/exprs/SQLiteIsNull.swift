import Dflat

extension IsNullExpr: SQLiteExpr where T: SQLiteExpr {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    clause.append("(")
    unary.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    clause.append(") ISNULL")
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    unary.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
  }
}
