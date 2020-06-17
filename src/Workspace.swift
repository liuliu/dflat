// MARK - Queries

public protocol Queryable {
  func fetchFor<Element: Atom>(_ ofType: Element.Type) -> QueryBuilder<Element>
  func fetchWithinASnapshot<T>(_: () -> T, ofType: T.Type) -> T
}

public extension Queryable {
  // Provide default implementation for cases we don't want to return values.
  func fetchWithinASnapshot(_ closure: () -> Void) -> Void {
    fetchWithinASnapshot(closure, ofType: Void.self)
  }
}

public protocol WorkspaceSubscription {
  func cancel()
}

public enum SubscribedObject<Element: Atom> {
  case updated(_: Element)
  case deleted
}

public protocol Workspace: Queryable {
  // MARK - Changes
  typealias ChangesHandler = (_ transactionContext: TransactionContext) -> Void
  typealias CompletionHandler = (_ success: Bool) -> Void
  func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler, completionHandler: CompletionHandler?)
  // MARK - Observations
  typealias Subscription = WorkspaceSubscription
  func subscribe<Element: Atom>(fetchedResult: FetchedResult<Element>, changeHandler: @escaping (_: FetchedResult<Element>) -> Void) -> Subscription where Element: Equatable
  func subscribe<Element: Atom>(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void) -> Subscription where Element: Equatable
}
