import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class AtomPublisher<Element: Atom>: Publisher where Element: Equatable {
  public typealias Output = SubscribedObject<Element>
  public typealias Failure = Never
  public init() {}
  open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    fatalError()
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class FetchedResultPublisher<Element: Atom>: Publisher where Element: Equatable {
  public typealias Output = FetchedResult<Element>
  public typealias Failure = Never
  public init() {}
  open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    fatalError()
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class QueryPublisher<Element: Atom>: Publisher where Element: Equatable {
  public typealias Output = FetchedResult<Element>
  public typealias Failure = Never
  public init() {}
  open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    fatalError()
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
open class QueryPublisherBuilder<Element: Atom> where Element: Equatable {
  public init() {}
  /**
   * Subscribe to a query against the Workspace. This is coupled with `publisher(for: Element.self)` method
   * and shouldn't be used independently.
   *
   * - Parameters:
   *    - query: The query such as `Post.title == "some title" && Post.color == .red`
   *    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
   *    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`
   *
   * - Returns: A publisher object that can be interacted with Combine.
   */
  open func `where`<T: Expr, OrderByType: OrderBy>(_ query: T, limit: Limit, orderBy: [OrderByType]) -> QueryPublisher<Element> where T.ResultType == Bool, T.Element == Element, OrderByType.Element == Element {
    fatalError()
  }
  public func `where`<T: Expr, OrderByType: OrderBy>(_ query: T, orderBy: [OrderByType]) -> QueryPublisher<Element> where T.ResultType == Bool, T.Element == Element, OrderByType.Element == Element {
    self.where(query, limit: .noLimit, orderBy: orderBy)
  }
  public func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit) -> QueryPublisher<Element> where T.ResultType == Bool, T.Element == Element {
    self.where(query, limit: limit, orderBy: [AnyOrderBy<Element>]())
  }
  /**
   * Subscribe to all changes to a class. This is coupled with `publisher(for: Element.self)` method
   * and shouldn't be used independently.
   *
   * - Parameters:
   *    - limit: The limit. Default to `.noLimit`, you can supply `.limit(number)`
   *    - orderBy: The array of keys to order the result. Such as `[Post.priority.descending]`
   *
   * - Returns: A publisher object that can be interacted with Combine.
   */
  open func all<OrderByType: OrderBy>(limit: Limit, orderBy: [OrderByType]) -> QueryPublisher<Element> where OrderByType.Element == Element {
    fatalError()
  }
  public func all<OrderByType: OrderBy>(orderBy: [OrderByType]) -> QueryPublisher<Element> where OrderByType.Element == Element {
    self.all(limit: .noLimit, orderBy: orderBy)
  }
  public func all(limit: Limit = .noLimit) -> QueryPublisher<Element> {
    self.all(limit: limit, orderBy: [AnyOrderBy<Element>]())
  }
}
