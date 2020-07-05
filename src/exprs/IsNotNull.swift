import FlatBuffers

public struct IsNotNullExpr<T: Expr, Element>: Expr where T.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  public let unary: T
  public func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    let val = unary.evaluate(object: object)
    return (!val.unknown, false)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    unary.canUsePartialIndex(indexSurvey) == .full ? .full : .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    unary.existingIndex(&existingIndexes)
  }
}

public extension Expr {
  var  isNotNull: IsNotNullExpr<Self, Self.Element> {
    IsNotNullExpr(unary: self)
  }
}
