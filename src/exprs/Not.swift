import FlatBuffers

public struct NotExpr<T: Expr, Element>: Expr where T.ResultType == Bool, T.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  @usableFromInline
  let unary: T
  @usableFromInline
  init(unary: T) {
    self.unary = unary
  }
  @inlinable
  public func evaluate(object: Element) -> ResultType? {
    guard let val = unary.evaluate(object: object) else { return nil }
    return !val
  }
  @inlinable
  public func evaluate(byteBuffer: ByteBuffer) -> ResultType? {
    guard let val = unary.evaluate(byteBuffer: byteBuffer) else { return nil }
    return !val
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

@inlinable
public prefix func ! <T, Element: Atom>(unary: T) -> NotExpr<T, Element>
where T.ResultType == Bool, T.Element == Element {
  return NotExpr(unary: unary)
}
