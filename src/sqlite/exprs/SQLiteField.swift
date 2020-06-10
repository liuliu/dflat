import Dflat

extension FieldExpr: SQLiteExpr {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    guard self.canUsePartialIndex(availableIndexes) == .full else { return }
    clause.append(self.name)
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {}
}
