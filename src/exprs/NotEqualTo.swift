import FlatBuffers

public struct NotEqualToExpr<L: Expr, R: Expr>: Expr where L.ResultType == R.ResultType, L.ResultType: Equatable {
  public typealias ResultType = Bool
  public let left: L
  public let right: R
  public func evaluate(table: FlatBufferObject?, object: Atom?) -> (result: ResultType, unknown: Bool) {
    let lval = left.evaluate(table: table, object: object)
    let rval = right.evaluate(table: table, object: object)
    return (lval.result != rval.result, lval.unknown || rval.unknown)
  }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    if left.canUsePartialIndex(availableIndexes) == .full && right.canUsePartialIndex(availableIndexes) == .full {
      return .full
    }
    return .none
  }
  public var useScanToRefine: Bool { left.useScanToRefine || right.useScanToRefine }
}

public func != <L, R>(left: L, right: R) -> NotEqualToExpr<L, R> where L.ResultType == R.ResultType, L.ResultType: Equatable {
  return NotEqualToExpr(left: left, right: right)
}

public func != <L, R>(left: L, right: R) -> NotEqualToExpr<L, ValueExpr<R>> where L.ResultType == R, R: Equatable {
  return NotEqualToExpr(left: left, right: ValueExpr(right))
}

public func != <L, R>(left: L, right: R) -> NotEqualToExpr<ValueExpr<L>, R> where L: Equatable, L == R.ResultType {
  return NotEqualToExpr(left: ValueExpr(left), right: right)
}
