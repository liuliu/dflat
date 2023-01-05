#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
  import Combine

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  open class AtomPublisher<Element: Atom & Equatable>: Publisher {
    public typealias Output = SubscribedObject<Element>
    public typealias Failure = Never
    public init() {}
    open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      fatalError()
    }
  }

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  open class DictionaryValuePublisher<Element: Equatable>: Publisher {
    public typealias Output = SubscribedDictionaryValue<Element>
    public typealias Failure = Never
    public init() {}
    open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      fatalError()
    }
  }

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  open class FetchedResultPublisher<Element: Atom & Equatable>: Publisher {
    public typealias Output = FetchedResult<Element>
    public typealias Failure = Never
    public init() {}
    open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      fatalError()
    }
  }

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  open class QueryPublisher<Element: Atom & Equatable>: Publisher {
    public typealias Output = FetchedResult<Element>
    public typealias Failure = Never
    public init() {}
    open func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
      fatalError()
    }
  }

  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  open class QueryPublisherBuilder<Element: Atom & Equatable> {
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
    open func `where`<T: Expr & SQLiteExpr>(
      _ query: T, limit: Limit = .noLimit, orderBy: [OrderBy<Element>] = []
    ) -> QueryPublisher<Element> where T.ResultType == Bool, T.Element == Element {
      fatalError()
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
    open func all(limit: Limit = .noLimit, orderBy: [OrderBy<Element>] = []) -> QueryPublisher<
      Element
    > {
      fatalError()
    }
  }

#endif
