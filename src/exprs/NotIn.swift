import FlatBuffers

public struct NotInExpr<T: Expr, Element>: Expr
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
  public func evaluate(object: Element) -> ResultType? {
    guard let val = unary.evaluate(object: object) else { return nil }
    return !set.contains(val)
  }
  @inlinable
  public func evaluate(byteBuffer: ByteBuffer) -> ResultType? {
    guard let val = unary.evaluate(byteBuffer: byteBuffer) else { return nil }
    return !set.contains(val)
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
  public func notIn<S>(_ sequence: S) -> NotInExpr<Self, Self.Element>
  where S: Sequence, S.Element == Self.ResultType {
    NotInExpr(unary: self, set: Set(sequence))
  }
}
