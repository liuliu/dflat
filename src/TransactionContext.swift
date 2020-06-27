public enum TransactionError: Error {
  case aborted // The transaction has been aborted already before submitting the request.
  case objectAlreadyExists // The object already exists. Conflict on either primary keys or unique properties
  case diskFull // We will rollback the whole transaction in case of disk full.
  case others // Other types of errors, in these cases, we will simply rollback the whole transaction.
}

public protocol TransactionContext {
  @discardableResult
  func submit(_: ChangeRequest) throws -> UpdatedObject
  @discardableResult
  func abort() -> Bool
}

public extension TransactionContext {
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
