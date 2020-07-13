import FlatBuffers

public struct OrExpr<L: Expr, R: Expr, Element>: Expr where L.ResultType == R.ResultType, L.ResultType == Bool, L.Element == R.Element, L.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    let lval = left.evaluate(object: object)
    if lval == true {
      return true
    }
    let rval = right.evaluate(object: object)
    // If any of these result is true and !unknown, the whole expression evaluated to true and !unknown
    if rval == true {
      return true
    }
    guard let lvalUnwrapped = lval, let rvalUnwrapped = rval else {
      return nil
    }
    return lvalUnwrapped || rvalUnwrapped
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

public func || <L, R, Element: Atom>(left: L, right: R) -> OrExpr<L, R, Element> where L.ResultType == R.ResultType, L.ResultType == Bool, L.Element == R.Element, L.Element == Element {
  return OrExpr(left: left, right: right)
}

public func || <L, Element: Atom>(left: L, right: Bool) -> OrExpr<L, ValueExpr<Bool, Element>, Element> where L.ResultType == Bool, L.Element == Element {
  return OrExpr(left: left, right: ValueExpr(right))
}

public func || <R, Element: Atom>(left: Bool, right: R) -> OrExpr<ValueExpr<Bool, Element>, R, Element> where R.ResultType == Bool, Element == R.Element {
  return OrExpr(left: ValueExpr(left), right: right)
}
