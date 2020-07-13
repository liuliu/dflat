import FlatBuffers

public struct LessThanExpr<L: Expr, R: Expr, Element>: Expr where L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element, L.Element == Element {
  public typealias ResultType = Bool
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let lval = left.evaluate(object: object), let rval = right.evaluate(object: object) else { return nil }
    return lval < rval
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

public func < <L, R, Element: Atom>(left: L, right: R) -> LessThanExpr<L, R, Element> where L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element, L.Element == Element {
  return LessThanExpr(left: left, right: right)
}

public func < <L, R, Element: Atom>(left: L, right: R) -> LessThanExpr<L, ValueExpr<R, Element>, Element> where L.ResultType == R, R: Comparable, L.Element == Element {
  return LessThanExpr(left: left, right: ValueExpr(right))
}

public func < <L, R, Element: Atom>(left: L, right: R) -> LessThanExpr<ValueExpr<L, Element>, R, Element> where L: Comparable, L == R.ResultType, Element == R.Element {
  return LessThanExpr(left: ValueExpr(left), right: right)
}

// GreaterThan is just a mirror of LessThan.

public func > <L, R, Element: Atom>(left: L, right: R) -> LessThanExpr<R, L, Element> where L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element, L.Element == Element {
  return LessThanExpr(left: right, right: left)
}

public func > <L, R, Element: Atom>(left: L, right: R) -> LessThanExpr<ValueExpr<R, Element>, L, Element> where L.ResultType == R, R: Comparable, L.Element == Element {
  return LessThanExpr(left: ValueExpr(right), right: left)
}

public func > <L, R, Element: Atom>(left: L, right: R) -> LessThanExpr<R, ValueExpr<L, Element>, Element> where L: Comparable, L == R.ResultType, Element == R.Element {
  return LessThanExpr(left: right, right: ValueExpr(left))
}
