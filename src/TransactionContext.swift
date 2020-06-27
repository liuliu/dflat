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
  func submit(_ changeRequest: ChangeRequest) throws {
    _ = try self.submit(changeRequest)
  }
}
