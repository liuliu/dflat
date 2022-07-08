import FlatBuffers

public struct InExpr<T: Expr, Element>: Expr
where T.ResultType: DflatFriendlyValue, T.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  @usableFromInline
  let unary: T
  @usableFromInline
  let set: Set<T.ResultType>
  @usableFromInline
  init(unary: T, set: Set<T.ResultType>) {
    self.unary = unary
    self.set = set
  }
  @inlinable
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let val = unary.evaluate(object: object) else { return nil }
    return set.contains(val)
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
  public func `in`<S>(_ sequence: S) -> InExpr<Self, Self.Element>
  where S: Sequence, S.Element == Self.ResultType {
    InExpr(unary: self, set: Set(sequence))
  }
}
