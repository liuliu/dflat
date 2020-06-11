import FlatBuffers

public struct NotExpr<T: Expr>: Expr where T.ResultType == Bool {
  public typealias ResultType = Bool
  public let unary: T
  public func evaluate(table: FlatBufferObject?, object: Atom?) -> (result: ResultType, unknown: Bool) {
    let val = unary.evaluate(table: table, object: object)
    return (!val.result, val.unknown)
  }
  public var useScanToRefine: Bool { unary.useScanToRefine }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    unary.canUsePartialIndex(availableIndexes) == .full ? .full : .none
  }
}

public prefix func ! <T>(unary: T) -> NotExpr<T> where T.ResultType == Bool {
  return NotExpr(unary: unary)
}
