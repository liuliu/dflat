import FlatBuffers

public protocol DflatFriendlyValue: Comparable {}

extension Bool: Comparable {
  public static func < (lhs: Bool, rhs: Bool) -> Bool {
    return lhs == false
  }
}

extension Bool: DflatFriendlyValue {}
extension Int8: DflatFriendlyValue {}
extension UInt8: DflatFriendlyValue {}
extension Int16: DflatFriendlyValue {}
extension UInt16: DflatFriendlyValue {}
extension Int32: DflatFriendlyValue {}
extension UInt32: DflatFriendlyValue {}
extension Int64: DflatFriendlyValue {}
extension UInt64: DflatFriendlyValue {}
extension Float: DflatFriendlyValue {}
extension Double: DflatFriendlyValue {}
extension String: DflatFriendlyValue {}

public struct ValueExpr<T>: Expr where T: DflatFriendlyValue {
  public typealias ResultType = T
  public let value: T
  internal init(_ value: T) {
    self.value = value
  }
  public func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool) {
    (value, false)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    .full
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {}
}
