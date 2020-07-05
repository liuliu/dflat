import FlatBuffers

public struct GreaterThanOrEqualToExpr<L: Expr, R: Expr, Element>: Expr where L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element, L.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(object: object)
    let rval = right.evaluate(object: object)
    return (lval.result >= rval.result, lval.unknown || rval.unknown)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    let lval = left.canUsePartialIndex(indexSurvey)
    let rval = right.canUsePartialIndex(indexSurvey)
    if lval == .full && rval == .full {
      return .full
    } else if lval != .none && rval != .none {
      return .partial
    }
    return .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    left.existingIndex(&existingIndexes)
    right.existingIndex(&existingIndexes)
  }
}

public func >= <L, R, Element: Atom>(left: L, right: R) -> GreaterThanOrEqualToExpr<L, R, Element> where L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element, L.Element == Element {
  return GreaterThanOrEqualToExpr(left: left, right: right)
}

public func >= <L, R, Element: Atom>(left: L, right: R) -> GreaterThanOrEqualToExpr<L, ValueExpr<R, Element>, Element> where L.ResultType == R, R: Comparable, L.Element == Element {
  return GreaterThanOrEqualToExpr(left: left, right: ValueExpr(right))
}

public func >= <L, R, Element: Atom>(left: L, right: R) -> GreaterThanOrEqualToExpr<ValueExpr<L, Element>, R, Element> where L: Comparable, L == R.ResultType, Element == R.Element {
  return GreaterThanOrEqualToExpr(left: ValueExpr(left), right: right)
}
