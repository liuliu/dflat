import Dflat

extension InExpr: SQLiteExpr where T: SQLiteExpr, T.ResultType: SQLiteValue {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    clause.append("(")
    unary.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    clause.append(") IN (")
    let count = set.count
    if count > 0 {
      parameterCount += 1
      clause.append("?\(parameterCount)")
    }
    for _ in 1..<count {
      parameterCount += 1
      clause.append("?\(parameterCount)")
    }
    clause.append(")")
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    unary.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
    for i in set {
      parameterCount += 1
      i.bindSQLite(clause, parameterId: parameterCount)
    }
  }
}
