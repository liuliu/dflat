import Dflat

extension AndExpr: SQLiteExpr where L: SQLiteExpr, R: SQLiteExpr {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    let lval = left.canUsePartialIndex(availableIndexes)
    let rval = right.canUsePartialIndex(availableIndexes)
    if lval != .none && rval != .none {
      clause.append("(")
      left.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
      clause.append(") AND (")
      right.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
      clause.append(")")
    } else if lval != .none {
      left.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    } else if rval != .none {
      right.buildWhereClause(availableIndexes: availableIndexes, clause: &clause, parameterCount: &parameterCount)
    }
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    if left.canUsePartialIndex(availableIndexes) != .none {
      left.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
    }
    if right.canUsePartialIndex(availableIndexes) != .none {
      right.bindWhereClause(availableIndexes: availableIndexes, clause: clause, parameterCount: &parameterCount)
    }
  }
}
