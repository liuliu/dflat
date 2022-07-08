import FlatBuffers

// See And.swift discussion for why we need 3-value.
public enum IndexUsefulness {
  case none
  case partial
  case full
}

public enum Evaluable<Element: Atom> {
  case table(_: ByteBuffer)
  case object(_: Element)
}

public struct IndexSurvey {
  public var full = Set<String>()
  public var partial = Set<String>()
  public var unavailable = Set<String>()
  public init() {}
}

public protocol Expr {
  associatedtype ResultType
  associatedtype Element: Atom
  func evaluate(object: Evaluable<Element>) -> ResultType?
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness
  func existingIndex(_ existingIndexes: inout Set<String>)
}
