// MARK - Queries

public protocol Queryable {
  /**
   * Return a QueryBuilder that you can make `where` or `all` queries against.
   */
  func fetch<Element: Atom>(for ofType: Element.Type) -> QueryBuilder<Element>
  /**
   * Provide a consistent view for fetching multiple objects at once.
   */
  func fetchWithinASnapshot<T>(_: () -> T) -> T
}

public protocol WorkspaceSubscription {
  /**
   * Cancel an existing subscription. It is guaranteed that no callback will happen
   * immediately after `cancel`.
   */
  func cancel()
}

public enum SubscribedObject<Element: Atom> {
  /**
   * Giving the updated object.
   */
  case updated(_: Element)
  /**
   * The object is deleted. This denotes the end of a subscription.
   */
  case deleted
}

public protocol Workspace: Queryable {
  // MARK - Management
  /**
   * Shutdown the Workspace. All transactions made to Dflat after this call will fail.
   * Transactions initiated before this will finish normally. Data fetching after this
   * will return empty results. Any data fetching triggered before this call will finish
   * normally, hence the `completion` part. The `completion` closure, if supplied, will
   * be called once all transactions and data fetching initiated before shutdown finish.
   */
  func shutdown(completion: (() -> Void)?)
  // MARK - Changes
  typealias ChangesHandler = (_ transactionContext: TransactionContext) -> Void
  typealias CompletionHandler = (_ success: Bool) -> Void
  /**
   * Perform a transaction for given object types.
   *
   * - Parameters:
   *    - transactionalObjectTypes: A list of object types you are going to transact with. If you
   *                                If you fetch or mutation an object outside of this list, it will fatal.
   *    - changesHandler: The transaction closure where you will give a transactionContext and safe to do
   *                      data mutations through submission of change requests.
   *    - completionHandler: If supplied, will be called once the transaction committed. It will be called
   *                         with success / failure. You don't need to handle failure cases specifically
   *                         (such as retry), but rather to surface and log such error.
   */
  func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler, completionHandler: CompletionHandler?)
  // MARK - Observations
  typealias Subscription = WorkspaceSubscription
  /**
   * Subscribe to changes of a fetched result. You queries fetched result with
   * `fetch(for:).where()` method and the result can be observed. If any object
   * created / updated meet the query criterion, the callback will happen and you
   * will get a updated fetched result.
   *
   * - Parameters:
   *    - fetchedResult: The original fetchedResult. If it is outdated already, you will get an updated
   *                     callback soon after.
   *    - changeHandler: The callback where you will receive an update if anything changed.
   *
   * - Returns: A subscription object that you can cancel the subscription. If no one hold the subscription
   *            object, it will cancel automatically.
   */
  func subscribe<Element: Atom>(fetchedResult: FetchedResult<Element>, changeHandler: @escaping (_: FetchedResult<Element>) -> Void) -> Subscription where Element: Equatable
  /**
   * Subscribe to changes of an object. If anything in the object changed or
   * the object itself is deleted. Deletion is a terminal event for subscription.
   * Even if later you inserted an object with the same primary key, the subscription
   * callback won't be triggered. This is different from fetched result subscription
   * above where if you query by primary key, you will get subscription update if
   * a new object with the same primary key later created.
   *
   * - Parameters:
   *    - object: The object to be observed. If it is outdated already, you will get an updated callback
   *              soon after.
   *    - changeHandler: The callback where you will receive an update if anything changed.
   *
   * - Returns: A subscription object that you can cancel on. If no one hold the subscription, it will cancel
   *            automatically.
   */
  func subscribe<Element: Atom>(object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void) -> Subscription where Element: Equatable
  // MARK - Combine-compliant
  /**
   * Return a publisher for object subscription in Combine.
   */
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func publisher<Element: Atom>(for: Element) -> AtomPublisher<Element> where Element: Equatable
  /**
   * Return a publisher for fetched result subscription in Combine.
   */
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func publisher<Element: Atom>(for: FetchedResult<Element>) -> FetchedResultPublisher<Element> where Element: Equatable
  /**
   * Return a publisher builder for query subscription in Combine.
   */
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  func publisher<Element: Atom>(for: Element.Type) -> QueryPublisherBuilder<Element> where Element: Equatable
}

public extension Workspace {
  func shutdown() {
    shutdown(completion: nil)
  }
  func performChanges(_ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler) {
    performChanges(transactionalObjectTypes, changesHandler: changesHandler, completionHandler: nil)
  }
}
