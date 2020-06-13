import FlatBuffers

// See And.swift discussion for why we need 3-value.
public enum IndexUsefulness {
  case none
  case partial
  case full
}

public enum Evaluable {
  case table(_: ByteBuffer)
  case object(_: Atom)
}

public protocol Expr {
  associatedtype ResultType
  func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool)
  func canUsePartialIndex(_ availableIndexes: Set<String>) -> IndexUsefulness
  var useScanToRefine: Bool { get }
}
