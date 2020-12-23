import FlatBuffers

public struct LessThanOrEqualToExpr<L: Expr, R: Expr, Element>: Expr
where
  L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element,
  L.Element == Element
{
  public typealias ResultType = Bool
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let lval = left.evaluate(object: object), let rval = right.evaluate(object: object) else {
      return nil
    }
    return lval <= rval
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

public func <= <L, R, Element: Atom>(left: L, right: R) -> LessThanOrEqualToExpr<L, R, Element>
where
  L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element,
  L.Element == Element
{
  return LessThanOrEqualToExpr(left: left, right: right)
}

public func <= <L, R, Element: Atom>(left: L, right: R) -> LessThanOrEqualToExpr<
  L, ValueExpr<R, Element>, Element
> where L.ResultType == R, R: Comparable, L.Element == Element {
  return LessThanOrEqualToExpr(left: left, right: ValueExpr(right))
}

public func <= <L, R, Element: Atom>(left: L, right: R) -> LessThanOrEqualToExpr<
  ValueExpr<L, Element>, R, Element
> where L: Comparable, L == R.ResultType, Element == R.Element {
  return LessThanOrEqualToExpr(left: ValueExpr(left), right: right)
}

// GreaterThanOrEqualTo is just a mirror of LessThanOrEqualTo.

public func >= <L, R, Element: Atom>(left: L, right: R) -> LessThanOrEqualToExpr<R, L, Element>
where
  L.ResultType == R.ResultType, L.ResultType: Comparable, L.Element == R.Element,
  L.Element == Element
{
  return LessThanOrEqualToExpr(left: right, right: left)
}

public func >= <L, R, Element: Atom>(left: L, right: R) -> LessThanOrEqualToExpr<
  ValueExpr<R, Element>, L, Element
> where L.ResultType == R, R: Comparable, L.Element == Element {
  return LessThanOrEqualToExpr(left: ValueExpr(right), right: left)
}

public func >= <L, R, Element: Atom>(left: L, right: R) -> LessThanOrEqualToExpr<
  R, ValueExpr<L, Element>, Element
> where L: Comparable, L == R.ResultType, Element == R.Element {
  return LessThanOrEqualToExpr(left: right, right: ValueExpr(left))
}
