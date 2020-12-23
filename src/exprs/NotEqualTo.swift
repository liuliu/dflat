import FlatBuffers

public struct NotEqualToExpr<L: Expr, R: Expr, Element>: Expr
where
  L.ResultType == R.ResultType, L.ResultType: Equatable, L.Element == R.Element,
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
    return lval != rval
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

public func != <L, R, Element: Atom>(left: L, right: R) -> NotEqualToExpr<L, R, Element>
where
  L.ResultType == R.ResultType, L.ResultType: Equatable, L.Element == R.Element,
  L.Element == Element
{
  return NotEqualToExpr(left: left, right: right)
}

public func != <L, R, Element: Atom>(left: L, right: R) -> NotEqualToExpr<
  L, ValueExpr<R, Element>, Element
> where L.ResultType == R, R: Equatable, L.Element == Element {
  return NotEqualToExpr(left: left, right: ValueExpr(right))
}

public func != <L, R, Element: Atom>(left: L, right: R) -> NotEqualToExpr<
  ValueExpr<L, Element>, R, Element
> where L: Equatable, L == R.ResultType, Element == R.Element {
  return NotEqualToExpr(left: ValueExpr(left), right: right)
}
