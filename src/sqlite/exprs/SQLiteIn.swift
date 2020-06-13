import Dflat

extension InExpr: SQLiteExpr where T: SQLiteExpr, T.ResultType: SQLiteValue {
  public func buildWhereQuery(availableIndexes: Set<String>, query: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    query.append("(")
    unary.buildWhereQuery(availableIndexes: availableIndexes, query: &query, parameterCount: &parameterCount)
    query.append(") IN (")
    let count = set.count
    if count > 0 {
      parameterCount += 1
      query.append("?\(parameterCount)")
    }
    for _ in 1..<count {
      parameterCount += 1
      query.append(", ?\(parameterCount)")
    }
    query.append(")")
  }
  public func bindWhereQuery(availableIndexes: Set<String>, query: OpaquePointer, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    unary.bindWhereQuery(availableIndexes: availableIndexes, query: query, parameterCount: &parameterCount)
    for i in set {
      parameterCount += 1
      i.bindSQLite(query, parameterId: parameterCount)
    }
  }
}
