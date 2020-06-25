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

public struct IndexSurvey {
  public var full = Set<String>()
  public var partial = Set<String>()
  public init() {}
}

public protocol Expr {
  associatedtype ResultType
  func evaluate(object: Evaluable) -> (result: ResultType, unknown: Bool)
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness
  func existingIndex(_ existingIndexes: inout Set<String>)
}
