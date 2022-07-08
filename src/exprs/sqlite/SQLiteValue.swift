public protocol SQLiteBinding {
  func bindSQLite(_ query: OpaquePointer, parameterId: Int32)
}

public protocol SQLiteValue: SQLiteBinding, DflatFriendlyValue {}

extension ValueExpr: SQLiteExpr where T: SQLiteValue {
  @inlinable
  public func buildWhereQuery(
    indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32
  ) {
    parameterCount += 1
    let parameterId = parameterCount
    query.append("?\(parameterId)")
  }
  @inlinable
  public func bindWhereQuery(
    indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32
  ) {
    parameterCount += 1
    let parameterId = parameterCount
    value.bindSQLite(query, parameterId: parameterId)
  }
}
