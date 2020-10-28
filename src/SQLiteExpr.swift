public protocol SQLiteExpr {
  func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32)
  func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32)
}

