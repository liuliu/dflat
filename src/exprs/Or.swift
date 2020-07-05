import FlatBuffers

public struct OrExpr<L: Expr, R: Expr>: Expr where L.ResultType == R.ResultType, L.ResultType == Bool {
  public typealias ResultType = Bool
  public let left: L
  public let right: R
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(object: object)
    if lval.result && !lval.unknown {
      return (true, false)
    }
    let rval = right.evaluate(object: object)
    // If any of these result is true and !unknown, the whole expression evaluated to true and !unknown
    if rval.result && !rval.unknown {
      return (true, false)
    } else {
      return (false, lval.unknown || rval.unknown)
    }
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

public func || <L, R>(left: L, right: R) -> OrExpr<L, R> where L.ResultType == R.ResultType, L.ResultType == Bool {
  return OrExpr(left: left, right: right)
}

public func || <L>(left: L, right: Bool) -> OrExpr<L, ValueExpr<Bool>> where L.ResultType == Bool {
  return OrExpr(left: left, right: ValueExpr(right))
}

public func || <R>(left: Bool, right: R) -> OrExpr<ValueExpr<Bool>, R> where R.ResultType == Bool {
  return OrExpr(left: ValueExpr(left), right: right)
}
