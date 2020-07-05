import FlatBuffers

public struct SubtractionExpr<L: Expr, R: Expr, Element>: Expr where L.ResultType == R.ResultType, L.ResultType: AdditiveArithmetic, L.Element == R.Element, L.Element == Element {
  public typealias ResultType = L.ResultType
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(object: object)
    let rval = right.evaluate(object: object)
    return (lval.result - rval.result, lval.unknown || rval.unknown)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    if left.canUsePartialIndex(indexSurvey) == .full && right.canUsePartialIndex(indexSurvey) == .full {
      return .full
    }
    return .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    left.existingIndex(&existingIndexes)
    right.existingIndex(&existingIndexes)
  }
}

public func - <L, R, Element: Atom>(left: L, right: R) -> SubtractionExpr<L, R, Element> where L.ResultType == R.ResultType, L.ResultType: AdditiveArithmetic, L.Element == R.Element, L.Element == Element {
  return SubtractionExpr(left: left, right: right)
}

public func - <L, R, Element: Atom>(left: L, right: R) -> SubtractionExpr<L, ValueExpr<R, Element>, Element> where L.ResultType == R, R: AdditiveArithmetic, L.Element == Element {
  return SubtractionExpr(left: left, right: ValueExpr(right))
}

public func - <L, R, Element: Atom>(left: L, right: R) -> SubtractionExpr<ValueExpr<L, Element>, R, Element> where L: AdditiveArithmetic, L == R.ResultType, Element == R.Element {
  return SubtractionExpr(left: ValueExpr(left), right: right)
}
