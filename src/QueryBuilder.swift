import FlatBuffers

public enum SortingOrder {
  case ascending
  case same
  case descending
}

public protocol OrderBy {
  var name: String { get }
  var sortingOrder: SortingOrder { get }
  func areInSortingOrder(_ lhs: Evaluable, _ rhs: Evaluable) -> SortingOrder
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness
  func existingIndex(_ existingIndexes: inout Set<String>)
}

public enum Limit {
  case noLimit
  case limit(_: Int)
}

// This can be converted to PAT if we can use `some`. That requires the whole Workspace object to be PAT such that the returned
// QueryBuilder can be an associated type.
open class QueryBuilder<Element: Atom> {
  public init() {}
  open func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> where T.ResultType == Bool {
    fatalError()
  }
  open func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> FetchedResult<Element> {
    fatalError()
  }
}
