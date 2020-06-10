import FlatBuffers

// See And.swift discussion for why we need 3-value.
public enum IndexUsefulness {
  case none
  case partial
  case full
}

public protocol Expr {
  associatedtype ResultType
  func evaluate(table: FlatBufferObject?, object: DflatAtom?) -> (result: ResultType, unknown: Bool)
  func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness
  var useScanToRefine: Bool { get }
}

public extension Expr {
  func evaluate(table: FlatBufferObject) -> (result: ResultType, unknown: Bool) {
    evaluate(table: table, object: nil)
  }
  func evaluate(object: DflatAtom) -> (result: ResultType, unknown: Bool) {
    evaluate(table: nil, object: object)
  }
}
