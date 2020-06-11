public protocol Queryable {
  func fetchFor<T: Atom>(ofType: T.Type) -> QueryBuilder<T>
  func fetchWithinASnapshot<T>(_: () -> T, ofType: T.Type) -> T
}

public extension Queryable {
  // Provide default implementation for cases we don't want to return values.
  func fetchWithinASnapshot(_ closure: () -> Void) -> Void {
    fetchWithinASnapshot(closure, ofType: Void.self)
  }
}

public protocol Workspace: Queryable {
  typealias ChangesHandler = (_ transactionContext: TransactionContext) -> Void
  typealias CompletionHandler = (_ success: Bool) -> Void
  func performChanges(_ anyPool: [Any.Type], changesHandler: @escaping ChangesHandler, completionHandler: CompletionHandler?)
}
