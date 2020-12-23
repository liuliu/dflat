import FlatBuffers

public struct AdditionExpr<L: Expr, R: Expr, Element>: Expr
where
  L.ResultType == R.ResultType, L.ResultType: AdditiveArithmetic, L.Element == R.Element,
  L.Element == Element
{
  public typealias ResultType = L.ResultType
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let lval = left.evaluate(object: object), let rval = right.evaluate(object: object) else {
      return nil
    }
    return lval + rval
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    if left.canUsePartialIndex(indexSurvey) == .full
      && right.canUsePartialIndex(indexSurvey) == .full
    {
      return .full
    }
    return .none
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    left.existingIndex(&existingIndexes)
    right.existingIndex(&existingIndexes)
  }
}

public func + <L, R, Element: Atom>(left: L, right: R) -> AdditionExpr<L, R, Element>
where
  L.ResultType == R.ResultType, L.ResultType: AdditiveArithmetic, L.Element == R.Element,
  L.Element == Element
{
  return AdditionExpr(left: left, right: right)
}

public func + <L, R, Element: Atom>(left: L, right: R) -> AdditionExpr<
  L, ValueExpr<R, Element>, Element
> where L.ResultType == R, R: AdditiveArithmetic, L.Element == Element {
  return AdditionExpr(left: left, right: ValueExpr(right))
}

public func + <L, R, Element: Atom>(left: L, right: R) -> AdditionExpr<
  ValueExpr<L, Element>, R, Element
> where L: AdditiveArithmetic, L == R.ResultType, Element == R.Element {
  return AdditionExpr(left: ValueExpr(left), right: right)
}
