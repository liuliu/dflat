// MARK - Queries

public protocol Queryable {
  func fetchFor<Element: Atom>(_ ofType: Element.Type) -> QueryBuilder<Element>
  func fetchWithinASnapshot<T>(_: () -> T) -> T
}

public protocol WorkspaceSubscription {
  func cancel()
}

public enum SubscribedObject<Element: Atom> {
  case updated(_: Element)
  case deleted
}

public protocol Workspace: Queryable {
  // MARK - Management
  func shutdown(completion: (() -> Void)?)
  // MARK - Changes
  typealias ChangesHandler = (_ transactionContext: TransactionContext) -> Void
  typealias CompletionHandler = (_ success: Bool) -> Void
  func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler, completionHandler: CompletionHandler?)
  // MARK - Observations
  typealias Subscription = WorkspaceSubscription
  func subscribe<Element: Atom>(fetchedResult: FetchedResult<Element>, changeHandler: @escaping (_: FetchedResult<Element>) -> Void) -> Subscription where Element: Equatable
  func subscribe<Element: Atom>(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void) -> Subscription where Element: Equatable
  // MARK - Combine-compliant
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func publisher<Element: Atom>(for: Element) -> AtomPublisher<Element> where Element: Equatable
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func publisher<Element: Atom>(for: FetchedResult<Element>) -> FetchedResultPublisher<Element> where Element: Equatable
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func publisher<Element: Atom>(for: Element.Type) -> QueryPublisherBuilder<Element> where Element: Equatable
}

public extension Workspace {
  func shutdown() {
    shutdown(completion: nil)
  }
}
