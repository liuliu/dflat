import FlatBuffers

public enum SortingOrder {
  case ascending
  case same
  case descending
}

public class OrderBy<Element: Atom> {
  public var name: String { fatalError() }
  public var sortingOrder: SortingOrder { fatalError() }
  public func areInSortingOrder(_ lhs: Element, _ rhs: Element)
    -> SortingOrder
  {
    fatalError()
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    fatalError()
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    fatalError()
  }
}

public enum Limit {
  case noLimit
  case limit(_: Int)
}

// This can be converted to PAT if we can use `some`. That requires the whole Workspace object to be PAT such that the returned
// QueryBuilder can be an associated type.
open class QueryBuilder<Element: Atom> {
  public init() {}
  /**
   * Make query against the Workspace. This is coupled with `fetch(for:)` method and shouldn't be used independently.
   *
   * - Parameters:
   *    - query: The query such as `Post.title == "some title" && Post.color == .red`
   *    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
   *    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`
   *
   * - Returns: Return a fetched result which interacts just like normal array.
   */
  open func `where`<T: Expr & SQLiteExpr>(
    _ query: T, limit: Limit = .noLimit, orderBy: [OrderBy<Element>] = []
  ) -> FetchedResult<Element> where T.ResultType == Bool, T.Element == Element {
    fatalError()
  }
  /**
   * Return all objects for a class.
   *
   * - Parameters:
   *    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
   *    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`
   *
   * - Returns: Return a fetched result which interacts just like normal array.
   */
  open func all(limit: Limit = .noLimit, orderBy: [OrderBy<Element>] = []) -> FetchedResult<Element>
  {
    fatalError()
  }
}
