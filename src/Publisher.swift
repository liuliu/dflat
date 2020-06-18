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
  open func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> where T.ResultType == Bool {
    fatalError()
  }
  open func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> {
    fatalError()
  }
}
