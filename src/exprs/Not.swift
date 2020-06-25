import FlatBuffers

public struct NotExpr<T: Expr>: Expr where T.ResultType == Bool {
  public typealias ResultType = Bool
  public let unary: T
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let val = unary.evaluate(object: object)
    return (!val.result, val.unknown)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    unary.canUsePartialIndex(indexSurvey) == .full ? .full : .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    unary.existingIndex(&existingIndexes)
  }
}

public prefix func ! <T>(unary: T) -> NotExpr<T> where T.ResultType == Bool {
  return NotExpr(unary: unary)
}
