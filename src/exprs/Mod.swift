import FlatBuffers

public struct ModExpr<L: Expr, R: Expr>: Expr where L.ResultType == R.ResultType, L.ResultType: BinaryInteger {
  public typealias ResultType = L.ResultType
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(object: object)
    let rval = right.evaluate(object: object)
    return (lval.result % rval.result, lval.unknown || rval.unknown)
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

public func % <L, R>(left: L, right: R) -> ModExpr<L, R> where L.ResultType == R.ResultType, L.ResultType: BinaryInteger {
  return ModExpr(left: left, right: right)
}

public func % <L, R>(left: L, right: R) -> ModExpr<L, ValueExpr<R>> where L.ResultType == R, L.ResultType: BinaryInteger {
  return ModExpr(left: left, right: ValueExpr(right))
}

public func % <L, R>(left: L, right: R) -> ModExpr<ValueExpr<L>, R> where L: BinaryInteger, L == R.ResultType {
  return ModExpr(left: ValueExpr(left), right: right)
}
