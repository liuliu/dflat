import Dflat
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteAtomPublisher<Element: Atom>: AtomPublisher<Element> where Element: Equatable {
  final class AtomSubscription<S: Subscriber>: Subscription where Failure == S.Failure, Output == S.Input {
    private let subscriber: S
    private weak var workspace: SQLiteWorkspace?
    private let object: Element
    private var subscription: Workspace.Subscription? = nil
    init(subscriber: S, workspace: SQLiteWorkspace?, object: Element) {
      self.subscriber = subscriber
      self.workspace = workspace
      self.object = object
    }
    func request(_ demand: Subscribers.Demand) {
      guard subscription == nil else { return }
      subscription = workspace?.subscribe(object: object) {[weak self] updatedObject in
        guard let self = self else { return }
        let _ = self.subscriber.receive(updatedObject)
        if case .deleted = updatedObject {
          self.subscriber.receive(completion: .finished)
        }
      }
    }
    func cancel() {
      subscription?.cancel()
    }
  }
  private weak var workspace: SQLiteWorkspace?
  private let object: Element
  init(workspace: SQLiteWorkspace, object: Element) {
    self.workspace = workspace
    self.object = object
  }
  override func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    subscriber.receive(subscription: AtomSubscription(subscriber: subscriber, workspace: workspace, object: object))
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteFetchedResultPublisher<Element: Atom>: FetchedResultPublisher<Element> where Element: Equatable {
  final class FetchedResultSubscription<S: Subscriber>: Subscription where Failure == S.Failure, Output == S.Input {
    private let subscriber: S
    private weak var workspace: SQLiteWorkspace?
    private let fetchedResult: FetchedResult<Element>
    private var subscription: Workspace.Subscription? = nil
    init(subscriber: S, workspace: SQLiteWorkspace?, fetchedResult: FetchedResult<Element>) {
      self.subscriber = subscriber
      self.workspace = workspace
      self.fetchedResult = fetchedResult
    }
    func request(_ demand: Subscribers.Demand) {
      guard subscription == nil else { return }
      subscription = workspace?.subscribe(fetchedResult: fetchedResult) {[weak self] updatedFetchedResult in
        guard let self = self else { return }
        let _ = self.subscriber.receive(updatedFetchedResult)
      }
    }
    func cancel() {
      subscription?.cancel()
    }
  }
  private weak var workspace: SQLiteWorkspace?
  private let fetchedResult: FetchedResult<Element>
  init(workspace: SQLiteWorkspace, fetchedResult: FetchedResult<Element>) {
    self.workspace = workspace
    self.fetchedResult = fetchedResult
  }
  override func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    subscriber.receive(subscription: FetchedResultSubscription(subscriber: subscriber, workspace: workspace, fetchedResult: fetchedResult))
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteQueryPublisher<Element: Atom>: QueryPublisher<Element> where Element: Equatable {
  final class QuerySubscription<S: Subscriber>: Subscription where Failure == S.Failure, Output == S.Input {
    private let subscriber: S
    private weak var workspace: SQLiteWorkspace?
    private let query: AnySQLiteExpr<Bool>
    private let limit: Limit
    private let orderBy: [OrderBy]
    private var subscription: Workspace.Subscription? = nil
    init(subscriber: S, workspace: SQLiteWorkspace?, query: AnySQLiteExpr<Bool>, limit: Limit, orderBy: [OrderBy]) {
      self.subscriber = subscriber
      self.workspace = workspace
      self.query = query
      self.limit = limit
      self.orderBy = orderBy
    }
    func request(_ demand: Subscribers.Demand) {
      guard subscription == nil else { return }
      guard let workspace = workspace else { return }
      // TODO: This can be optimized. Subscription can share publishers and use publisher to get fetchedResult.
      let fetchedResult = workspace.fetchFor(Element.self).where(query, limit: limit, orderBy: orderBy)
      let _ = subscriber.receive(fetchedResult)
      subscription = workspace.subscribe(fetchedResult: fetchedResult) {[weak self] updatedFetchedResult in
        guard let self = self else { return }
        let _ = self.subscriber.receive(updatedFetchedResult)
      }
    }
    func cancel() {
      subscription?.cancel()
    }
  }
  private weak var workspace: SQLiteWorkspace?
  private let query: AnySQLiteExpr<Bool>
  private let limit: Limit
  private let orderBy: [OrderBy]
  init<T: Expr>(workspace: SQLiteWorkspace, query: T, limit: Limit, orderBy: [OrderBy]) where T.ResultType == Bool {
    self.workspace = workspace
    self.query = AnySQLiteExpr(query, query as! SQLiteExpr)
    self.limit = limit
    self.orderBy = orderBy
  }
  override func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
    subscriber.receive(subscription: QuerySubscription(subscriber: subscriber, workspace: workspace, query: query, limit: limit, orderBy: orderBy))
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteQueryPublisherBuilder<Element: Atom>: QueryPublisherBuilder<Element> where Element: Equatable {
  private let workspace: SQLiteWorkspace
  init(workspace: SQLiteWorkspace) {
    self.workspace = workspace
  }
  override func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> where T.ResultType == Bool {
    return SQLiteQueryPublisher<Element>(workspace: workspace, query: query, limit: limit, orderBy: orderBy)
  }
  override func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> {
    return SQLiteQueryPublisher<Element>(workspace: workspace, query: AllExpr(), limit: limit, orderBy: orderBy)
  }
}
