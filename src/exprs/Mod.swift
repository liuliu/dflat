import FlatBuffers

public struct ModExpr<L: Expr, R: Expr, Element>: Expr where L.ResultType == R.ResultType, L.ResultType: BinaryInteger, L.Element == R.Element, L.Element == Element {
  public typealias ResultType = L.ResultType
  public typealias Element = Element
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable<Element>) -> ResultType? {
    guard let lval = left.evaluate(object: object), let rval = right.evaluate(object: object) else { return nil }
    return lval % rval
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

public func % <L, R, Element: Atom>(left: L, right: R) -> ModExpr<L, R, Element> where L.ResultType == R.ResultType, L.ResultType: BinaryInteger, L.Element == R.Element, L.Element == Element {
  return ModExpr(left: left, right: right)
}

public func % <L, R, Element: Atom>(left: L, right: R) -> ModExpr<L, ValueExpr<R, Element>, Element> where L.ResultType == R, L.ResultType: BinaryInteger, L.Element == Element {
  return ModExpr(left: left, right: ValueExpr(right))
}

public func % <L, R, Element: Atom>(left: L, right: R) -> ModExpr<ValueExpr<L, Element>, R, Element> where L: BinaryInteger, L == R.ResultType, Element == R.Element {
  return ModExpr(left: ValueExpr(left), right: right)
}
