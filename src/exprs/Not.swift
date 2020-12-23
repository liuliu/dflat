import FlatBuffers

public struct NotExpr<T: Expr, Element>: Expr where T.ResultType == Bool, T.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  public let unary: T
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let val = unary.evaluate(object: object) else { return nil }
    return !val
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    unary.canUsePartialIndex(indexSurvey) == .full ? .full : .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    unary.existingIndex(&existingIndexes)
  }
}

public prefix func ! <T, Element: Atom>(unary: T) -> NotExpr<T, Element>
where T.ResultType == Bool, T.Element == Element {
  return NotExpr(unary: unary)
}
