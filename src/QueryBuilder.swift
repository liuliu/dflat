import FlatBuffers

public enum SortingOrder {
  case ascending
  case same
  case descending
}

public protocol OrderBy {
  associatedtype Element: Atom
  var name: String { get }
  var sortingOrder: SortingOrder { get }
  func areInSortingOrder(_ lhs: Evaluable<Element>, _ rhs: Evaluable<Element>) -> SortingOrder
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness
  func existingIndex(_ existingIndexes: inout Set<String>)
}

private class _AnyOrderByBase<Element: Atom>: OrderBy {
  public typealias Element = Element
  var name: String { fatalError() }
  var sortingOrder: SortingOrder { fatalError() }
  func areInSortingOrder(_ lhs: Evaluable<Element>, _ rhs: Evaluable<Element>) -> SortingOrder {
    fatalError()
  }
  func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    fatalError()
  }
  func existingIndex(_ existingIndexes: inout Set<String>) {
    fatalError()
  }
}

private class _AnyOrderBy<T: OrderBy, Element>: _AnyOrderByBase<Element> where T.Element == Element {
  private let base: T
  init(_ base: T) {
    self.base = base
  }
  override var name: String { base.name }
  override var sortingOrder: SortingOrder { base.sortingOrder }
  override func areInSortingOrder(_ lhs: Evaluable<Element>, _ rhs: Evaluable<Element>) -> SortingOrder {
    base.areInSortingOrder(lhs, rhs)
  }
  override func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    base.canUsePartialIndex(indexSurvey)
  }
  override func existingIndex(_ existingIndexes: inout Set<String>) {
    base.existingIndex(&existingIndexes)
  }
}

// We have to declare the type-erased here because we use it to provide empty array.
// We can provide an empty array with a EmptyOrderBy: OrderBy, however, that just additional
// type with no better gain.
public final class AnyOrderBy<Element: Atom>: OrderBy {
  public typealias Element = Element
  private let base: _AnyOrderByBase<Element>
  public init<T: OrderBy>(_ base: T) where T.Element == Element {
    self.base = _AnyOrderBy(base)
  }
  public var name: String { base.name }
  public var sortingOrder: SortingOrder { base.sortingOrder }
  public func areInSortingOrder(_ lhs: Evaluable<Element>, _ rhs: Evaluable<Element>) -> SortingOrder {
    base.areInSortingOrder(lhs, rhs)
  }
  public func canUsePartialIndex(_ indexSurvey: IndexSurvey) -> IndexUsefulness {
    base.canUsePartialIndex(indexSurvey)
  }
  public func existingIndex(_ existingIndexes: inout Set<String>) {
    base.existingIndex(&existingIndexes)
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
  open func `where`<T: Expr, OrderByType: OrderBy>(_ query: T, limit: Limit, orderBy: [OrderByType]) -> FetchedResult<Element> where T.ResultType == Bool, T.Element == Element, OrderByType.Element == Element {
    fatalError()
  }
  public func `where`<T: Expr, OrderByType: OrderBy>(_ query: T, orderBy: [OrderByType]) -> FetchedResult<Element> where T.ResultType == Bool, T.Element == Element, OrderByType.Element == Element {
    self.where(query, limit: .noLimit, orderBy: orderBy)
  }
  public func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit) -> FetchedResult<Element> where T.ResultType == Bool, T.Element == Element {
    self.where(query, limit: limit, orderBy: [AnyOrderBy<Element>]())
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
  open func all<OrderByType: OrderBy>(limit: Limit, orderBy: [OrderByType]) -> FetchedResult<Element> where OrderByType.Element == Element {
    fatalError()
  }
  public func all<OrderByType: OrderBy>(orderBy: [OrderByType]) -> FetchedResult<Element> where OrderByType.Element == Element {
    self.all(limit: .noLimit, orderBy: orderBy)
  }
  public func all(limit: Limit = .noLimit) -> FetchedResult<Element> {
    self.all(limit: limit, orderBy: [AnyOrderBy<Element>]())
  }
}
