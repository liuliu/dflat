import FlatBuffers

public struct NotInExpr<T: Expr>: Expr where T.ResultType: Hashable, T.ResultType: DflatFriendlyValue {
  public typealias ResultType = Bool
  public let unary: T
  public let set: Set<T.ResultType>
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    let val = unary.evaluate(object: object)
    guard (!val.unknown) else { return (false, true) }
    return (!set.contains(val.result), false)
  }
  public func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness {
    unary.canUsePartialIndex(availableIndexes) == .full ? .full : .none
  }
}

public extension Expr {
  func notIn<S>(_ sequence: S) -> NotInExpr<Self> where S: Sequence, S.Element == Self.ResultType {
    NotInExpr(unary: self, set: Set(sequence))
  }
}
