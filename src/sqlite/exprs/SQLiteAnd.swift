import Dflat

extension AndExpr: SQLiteExpr where L: SQLiteExpr, R: SQLiteExpr {
  public func buildWhereQuery(availableIndexes: Set<String>, query: inout String, parameterCount: inout Int32) {
    let lval = left.canUsePartialIndex(availableIndexes)
    let rval = right.canUsePartialIndex(availableIndexes)
    if lval != .none && rval != .none {
      query.append("(")
      left.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
      query.append(") AND (")
      right.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
      query.append(")")
    } else if lval != .none {
      left.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
    } else if rval != .none {
      right.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
    }
  }
  public func bindWhereQuery(availableIndexes: Set<String>, query: OpaquePointer, parameterCount: inout Int32) {
    if left.canUsePartialIndex(availableIndexes) != .none {
      left.bindWhereQuery(availableIndexes: availableIndexes, query: query, parameterCount: &parameterCount)
    }
    if right.canUsePartialIndex(availableIndexes) != .none {
      right.bindWhereQuery(availableIndexes: availableIndexes, query: query, parameterCount: &parameterCount)
    }
  }
}
