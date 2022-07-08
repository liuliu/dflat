import FlatBuffers

public struct ModExpr<L: Expr, R: Expr, Element>: Expr
where
  L.ResultType == R.ResultType, L.ResultType: BinaryInteger, L.Element == R.Element,
  L.Element == Element
{
  public typealias ResultType = L.ResultType
  public typealias Element = Element
  @usableFromInline
  let left: L
  @usableFromInline
  let right: R
  @usableFromInline
  init(left: L, right: R) {
    self.left = left
    self.right = right
  }
  @inlinable
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let lval = left.evaluate(object: object), let rval = right.evaluate(object: object) else {
      return nil
    }
    return lval % rval
  }
  @inlinable
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    if left.canUsePartialIndex(indexSurvey) == .full
      && right.canUsePartialIndex(indexSurvey) == .full
    {
      return .full
    }
    return .none
  }
  @inlinable
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    left.existingIndex(&existingIndexes)
    right.existingIndex(&existingIndexes)
  }
}

@inlinable
public func % <L, R, Element: Atom>(left: L, right: R) -> ModExpr<L, R, Element>
where
  L.ResultType == R.ResultType, L.ResultType: BinaryInteger, L.Element == R.Element,
  L.Element == Element
{
  return ModExpr(left: left, right: right)
}

@inlinable
public func % <L, R, Element: Atom>(left: L, right: R) -> ModExpr<L, ValueExpr<R, Element>, Element>
where L.ResultType == R, L.ResultType: BinaryInteger, L.Element == Element {
  return ModExpr(left: left, right: ValueExpr(right))
}

@inlinable
public func % <L, R, Element: Atom>(left: L, right: R) -> ModExpr<ValueExpr<L, Element>, R, Element>
where L: BinaryInteger, L == R.ResultType, Element == R.Element {
  return ModExpr(left: ValueExpr(left), right: right)
}
