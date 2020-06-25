import FlatBuffers

public struct IsNullExpr<T: Expr>: Expr {
  public typealias ResultType = Bool
  public let unary: T
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let val = unary.evaluate(object: object)
    return (val.unknown, false)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    unary.canUsePartialIndex(indexSurvey) == .full ? .full : .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    unary.existingIndex(&existingIndexes)
  }
}

public extension Expr {
  var isNull: IsNullExpr<Self> {
    IsNullExpr(unary: self)
  }
}
