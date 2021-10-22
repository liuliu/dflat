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

public protocol WorkspaceDictionary {
  /**
   * Get the latest value, whether it is in memory or from disk.
   * Set the value, it will persist asynchronously.
   */
  subscript<T: Codable & Equatable>(_: String, _: T.Type) -> T? { get set }
  subscript<T: FlatBuffersCodable & Equatable>(_: String, _: T.Type) -> T? { get set }
  subscript(_: String, _: Bool.Type) -> Bool? { get set }
  subscript(_: String, _: Int.Type) -> Int? { get set }
  subscript(_: String, _: UInt.Type) -> UInt? { get set }
  subscript(_: String, _: Float.Type) -> Float? { get set }
  subscript(_: String, _: Double.Type) -> Double? { get set }
  subscript(_: String, _: String.Type) -> String? { get set }
  /**
   * Force current thread to wait until everything has been written to disk.
   * Note that this function forces wait to disk, but not synchronize across
   * threads. You could have one thread called synchronize while another thread
   * is still holding their own lock to update in-memory value. It doesn't guarantee
   * the first thread will wait the second thread's dictionary[key] = value to finish.
   * This method only guarantees all writes on current thread done.
   */
  func synchronize()
  /**
   * Return all keys available in the dictionary. This is an expensive (for this dictionary)
   * method as it fetches from disk, from in-memory structures, and acquire locks if needed.
   */
  var keys: [String] { get }
  /**
   * Remove all key-value pairs in the dictionary. Like `keys`, this is an expensive method
   * in the sense that it needs to acquire locks for all in-memory structures. But it is not
   * as expensive as `keys` because the deletion from disk is asynchronous (no need to wait
   * fetching from disk).
   */
  mutating func removeAll()
}

public protocol Workspace: Queryable {
  // MARK - Management
  /**
   * Shutdown the Workspace. All transactions made to Dflat after this call will fail.
   * Transactions initiated before this will finish normally. Data fetching after this
   * will return empty results. Any data fetching triggered before this call will finish
   * normally, hence the `completion` part. The `completion` closure, if supplied, will
   * be called once all transactions and data fetching initiated before shutdown finish.
   * If `completion` closure not provided, this call will wait until all finished before
   * return.
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
  func performChanges(
    _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler,
    completionHandler: CompletionHandler?)
  #if compiler(>=5.5) && canImport(_Concurrency)
    /**
   * Perform a transaction for given object types and await either success or failure boolean.
   *
   * - Parameters:
   *    - transactionalObjectTypes: A list of object types you are going to transact with. If you
   *                                If you fetch or mutation an object outside of this list, it will fatal.
   *    - changesHandler: The transaction closure where you will give a transactionContext and safe to do
   *                      data mutations through submission of change requests.
   */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    @discardableResult
    func performChanges(
      _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler
    ) async -> Bool
  #endif
  /**
   * A persisted, in-memory cached key-value storage backed by current Workspace.
   * While writing data to disk is serialized under the hood, we don't wait the
   * writes. This dictionary is an class object, it is always mutable.
   */
  var dictionary: WorkspaceDictionary { get }
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
  func subscribe<Element: Atom>(
    fetchedResult: FetchedResult<Element>,
    changeHandler: @escaping (_: FetchedResult<Element>) -> Void
  ) -> Subscription where Element: Equatable
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
  func subscribe<Element: Atom>(
    object: Element, changeHandler: @escaping (_: SubscribedObject<Element>) -> Void
  ) -> Subscription where Element: Equatable
  #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    // MARK - Combine-compliant
    /**
   * Return a publisher for object subscription in Combine.
   */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher<Element: Atom>(for: Element) -> AtomPublisher<Element> where Element: Equatable
    /**
   * Return a publisher for fetched result subscription in Combine.
   */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher<Element: Atom>(for: FetchedResult<Element>) -> FetchedResultPublisher<Element>
    where Element: Equatable
    /**
   * Return a publisher builder for query subscription in Combine.
   */
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func publisher<Element: Atom>(for: Element.Type) -> QueryPublisherBuilder<Element>
    where Element: Equatable
  #endif
}

extension WorkspaceDictionary {
  /**
   * Get the value without type specifier.
   */
  public subscript<T: Codable & Equatable>(key: String) -> T? {
    get { self[key, T.self] }
    set { self[key, T.self] = newValue }
  }
  public subscript<T: FlatBuffersCodable & Equatable>(key: String) -> T? {
    get { self[key, T.self] }
    set { self[key, T.self] = newValue }
  }
  public subscript(key: String) -> Bool? {
    get { self[key, Bool.self] }
    set { self[key, Bool.self] = newValue }
  }
  public subscript(key: String) -> Int? {
    get { self[key, Int.self] }
    set { self[key, Int.self] = newValue }
  }
  public subscript(key: String) -> UInt? {
    get { self[key, UInt.self] }
    set { self[key, UInt.self] = newValue }
  }
  public subscript(key: String) -> Float? {
    get { self[key, Float.self] }
    set { self[key, Float.self] = newValue }
  }
  public subscript(key: String) -> Double? {
    get { self[key, Double.self] }
    set { self[key, Double.self] = newValue }
  }
  public subscript(key: String) -> String? {
    get { self[key, String.self] }
    set { self[key, String.self] = newValue }
  }
}

extension WorkspaceDictionary {
  /**
   * Get the latest value, whether it is in memory or from disk.
   * If the value is not available, use the default one. It won't
   * persist the default value into memory or disk. Thus, if you
   * call this method again with different default value (while
   * the underlying kept nil), it will return that different default
   * value.
   */
  public subscript<T: Codable & Equatable>(key: String, default value: T) -> T {
    get { self[key] ?? value }
  }
  public subscript<T: FlatBuffersCodable & Equatable>(key: String, default value: T) -> T {
    get { self[key] ?? value }
  }
  public subscript(key: String, default value: Bool) -> Bool {
    get { self[key] ?? value }
  }
  public subscript(key: String, default value: Int) -> Int {
    get { self[key] ?? value }
  }
  public subscript(key: String, default value: UInt) -> UInt {
    get { self[key] ?? value }
  }
  public subscript(key: String, default value: Float) -> Float {
    get { self[key] ?? value }
  }
  public subscript(key: String, default value: Double) -> Double {
    get { self[key] ?? value }
  }
  public subscript(key: String, default value: String) -> String {
    get { self[key] ?? value }
  }
}

extension Workspace {
  public func shutdown() {
    shutdown(completion: nil)
  }
  public func performChanges(
    _ transactionalObjectTypes: [Any.Type], changesHandler: @escaping ChangesHandler
  ) {
    performChanges(transactionalObjectTypes, changesHandler: changesHandler, completionHandler: nil)
  }
}
