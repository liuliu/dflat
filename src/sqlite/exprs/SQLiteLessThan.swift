import Dflat

extension LessThanExpr: SQLiteExpr where L: SQLiteExpr, R: SQLiteExpr {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    clause.append("(")
    left.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    clause.append(") < (")
    right.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    clause.append(")")
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    left.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
    right.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
  }
}
