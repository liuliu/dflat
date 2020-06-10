import FlatBuffers

public struct AndExpr<L: Expr, R: Expr>: Expr where L.ResultType == R.ResultType, L.ResultType == Bool {
  public typealias ResultType = Bool
  public let left: L
  public let right: R
  public func evaluate(table: FlatBufferObject?, object: DflatAtom?) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(table: table, object: object)
    let rval = right.evaluate(table: table, object: object)
    // If any of these result is false and !unknown, the whole expression evaluated to false and !unknown
    if ((!lval.result && !lval.unknown) || (!rval.result && !rval.unknown)) {
      return (lval.result && rval.result, lval.unknown && rval.unknown)
    } else {
      return (lval.result && rval.result, lval.unknown || rval.unknown)
    }
  }
  /*
   * All expressions except And would return either .full or .none for index usefulness. Thus, if a field
   * is not fully indexed, we won't generate indexed query. This is because it will result invalid result.
   * For example, for a query (field1 = 1 OR field2 = 2), if field2 is removed because no index available,
   * it will wrongfully exclude results that field1 != 1 but field2 = 2 (because the OR operator). Later
   * scan operation won't recover that information because we started from a reduced dataset.
   *
   * IndexUsefulness reconcile these cases. For most binary / unary operators, if IndexUsefulness is not .full,
   * it is .none, meaning we cannot reliably rely on partial index. For above OR operator, because field1 has
   * .full while field2 has .none, it will return .none, and will effectively do a full-scan. However, partial
   * index is still useful for a very limited case, such as below. For (field1 = 1 AND field2 = 2), because AND
   * operator, using field1 index can still be helpful and we can start scan from a reduced dataset. It will be
   * more efficient.
   *
   * So far, we haven't touched why it is 3-value. It seems we can just have two value: .full and .none, for AND
   * operator, we can simply return .full if either of them returns .full. The gotcha comes from the combination.
   * Considering (NOT (field1 = 1 AND field2 = 2)), in this case, we cannot only use index for field1 because
   * (NOT field1 = 1) will give us a wrong reduced dataset, for cases (field1 = 1 AND field2 != 2), we wrongly
   * excluded them from the reduced dataset. For this case, we need to have the 3rd state: .partial. Any other
   * operator will binarize .partial into .none. So a NOT operator over AND of .partial state will return .none,
   * and we won't apply the index for field1. All is good.
   */
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    let lval = left.canUsePartialIndex(availableIndexes)
    let rval = right.canUsePartialIndex(availableIndexes)
    if lval == .full && rval == .full {
      return .full
    } else if lval != .none || rval != .none {
      return .partial
    }
    return .none
  }
  public var useScanToRefine: Bool { left.useScanToRefine || right.useScanToRefine }
}

public func && <L, R>(left: L, right: R) -> AndExpr<L, R> where L.ResultType == R.ResultType, L.ResultType == Bool {
  return AndExpr(left: left, right: right)
}

public func && <L>(left: L, right: Bool) -> AndExpr<L, ValueExpr<Bool>> where L.ResultType == Bool {
  return AndExpr(left: left, right: ValueExpr(right))
}

public func && <R>(left: Bool, right: R) -> AndExpr<ValueExpr<Bool>, R> where R.ResultType == Bool {
  return AndExpr(left: ValueExpr(left), right: right)
}
