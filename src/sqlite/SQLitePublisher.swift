import Dflat
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteAtomPublisher<Element: Atom>: AtomPublisher<Element> where Element: Equatable {
  final class AtomSubscription<S: Subscriber>: Subscription where Failure == S.Failure, Output == S.Input {
    private weak var workspace: SQLiteWorkspace?
    private let subscriber: S
    private var subscription: Workspace.Subscription? = nil
    private let object: Element
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
  override func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteQueryPublisher<Element: Atom>: QueryPublisher<Element> where Element: Equatable {
  override func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
  }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SQLiteQueryPublisherBuilder<Element: Atom>: QueryPublisherBuilder<Element> where Element: Equatable {
  override func `where`<T: Expr>(_ query: T, limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> where T.ResultType == Bool {
    return SQLiteQueryPublisher<Element>()
  }
  override func all(limit: Limit = .noLimit, orderBy: [OrderBy] = []) -> QueryPublisher<Element> {
    return SQLiteQueryPublisher<Element>()
  }
}
