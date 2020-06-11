import FlatBuffers

public enum SortingOrder {
  case ascending
  case descending
}

public protocol OrderBy {
  var name: String { get }
  var sortingOrder: SortingOrder { get }
  func areInIncreasingOrder(_ a: FlatBufferObject, _ b: FlatBufferObject) -> Bool
  func areInIncreasingOrder(_ a: Atom, _ b: Atom) -> Bool
}

public enum Limit {
  case noLimit
  case limit(_: Int)
}

// This can be converted to PAT if we can use `some`. That requires the whole Dflat object to be PAT such that the returned
// DflatQueryBuilder can be an associated type.
open class QueryBuilder<Element: Atom> {
  public init() {}
  open func `where`<T: Expr>(_ clause: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> where T.ResultType == Bool {
    fatalError()
  }
}
