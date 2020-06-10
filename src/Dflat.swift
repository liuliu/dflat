public protocol Dflat {
  typealias ChangesHandler = (_ transactionContext: DflatTransactionContext) -> Void
  typealias CompletionHandler = (_ success: Bool) -> Void
  func performChanges(_ anyPool: [Any.Type], changesHandler: @escaping ChangesHandler, completionHandler: CompletionHandler?)
  func fetchFor<T: DflatAtom>(ofType: T.Type) -> DflatQueryBuilder<T>
}
