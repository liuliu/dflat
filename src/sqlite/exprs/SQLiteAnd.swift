import Dflat

extension AndExpr: SQLiteExpr where L: SQLiteExpr, R: SQLiteExpr {
  public func buildWhereQuery(indexSurvey: IndexSurvey, query: inout String, parameterCount: inout Int32) {
    let lval = left.canUsePartialIndex(indexSurvey)
    let rval = right.canUsePartialIndex(indexSurvey)
    if lval != .none && rval != .none {
      query.append("(")
      left.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
      query.append(") AND (")
      right.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
      query.append(")")
    } else if lval != .none {
      left.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
    } else if rval != .none {
      right.buildWhereQuery(indexSurvey: indexSurvey, query: &query, parameterCount: &parameterCount)
    }
  }
  public func bindWhereQuery(indexSurvey: IndexSurvey, query: OpaquePointer, parameterCount: inout Int32) {
    if left.canUsePartialIndex(indexSurvey) != .none {
      left.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
    }
    if right.canUsePartialIndex(indexSurvey) != .none {
      right.bindWhereQuery(indexSurvey: indexSurvey, query: query, parameterCount: &parameterCount)
    }
  }
}
