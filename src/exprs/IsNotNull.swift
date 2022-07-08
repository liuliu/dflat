import FlatBuffers

public struct IsNotNullExpr<T: Expr, Element>: Expr where T.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  @usableFromInline
  let unary: T
  @usableFromInline
  init(unary: T) {
    self.unary = unary
  }
  @inlinable
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    return unary.evaluate(object: object) != nil
  }
  @inlinable
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    unary.canUsePartialIndex(indexSurvey) == .full ? .full : .none
  }
  @inlinable
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    unary.existingIndex(&existingIndexes)
  }
}

extension Expr {
  @inlinable
  public var isNotNull: IsNotNullExpr<Self, Self.Element> {
    IsNotNullExpr(unary: self)
  }
}
