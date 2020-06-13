import FlatBuffers

public struct IsNotNullExpr<T: Expr>: Expr {
  public typealias ResultType = Bool
  public let unary: T
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let val = unary.evaluate(object: object)
    return (!val.unknown, false)
  }
  public var useScanToRefine: Bool { unary.useScanToRefine }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    unary.canUsePartialIndex(availableIndexes) == .full ? .full : .none
  }
}

public extension Expr {
  var  isNotNull: IsNotNullExpr<Self> {
    IsNotNullExpr(unary: self)
  }
}
