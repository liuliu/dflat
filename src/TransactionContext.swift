public enum TransactionError: Error {
  /**
   * The transaction has been aborted already before submitting the request.
   */
  case aborted
  /**
   * The object already exists. Conflict on either primary keys or unique properties.
   */
  case objectAlreadyExists
  /**
   * We will rollback the whole transaction in case of disk full.
   */
  case diskFull
  /**
   * Other types of errors, in these cases, we will simply rollback the whole transaction.
   */
  case others
}

public protocol TransactionContext {
  /**
   * Submit a change request in a transaction. The change will be available immediately inside this
   * transaction and will be available once the transaction closure is done to everyone outside of
   * the transaction closure. It throws a TransactionError if there are errors. Otherwise, return
   * UpdatedObject to denote whether you inserted, updated or deleted an object.
   */
  @discardableResult
  func submit(_: ChangeRequest) throws -> UpdatedObject
  /**
   * Abort the current transaction. This will cause whatever happened inside the current transaction
   * to rollback immediately, and anything submitted after abort will throw TransactionError.aborted
   * error.
   */
  @discardableResult
  func abort() -> Bool
}

public extension TransactionContext {
  /**
   * Convenient method for submit change request. `submit()` may throw exceptions, but `try(submit:)` will
   * not. Rather, it will fatal in case of TransactionError.objectAlreadyExists. For any other types of
   * TransactionError, it will simply return nil.
   */
  @discardableResult
  func `try`(submit changeRequest: ChangeRequest) -> UpdatedObject? {
    do {
      return try self.submit(changeRequest)
    } catch TransactionError.objectAlreadyExists {
      fatalError("Object you try to insert already exists. Potentially a conflict unique index or primary key?")
    } catch {
      return nil
    }
  }
}
