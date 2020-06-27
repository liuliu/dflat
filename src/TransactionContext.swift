public enum TransactionError: Error {
  case aborted // The transaction has been aborted already before submitting the request.
  case objectAlreadyExists // The object already exists. Conflict on either primary keys or unique properties
  case diskFull // We will rollback the whole transaction in case of disk full.
  case others // Other types of errors, in these cases, we will simply rollback the whole transaction.
}

public protocol TransactionContext {
  // The returned result is guaranteed to be non-nil. However, this is IMO because
  // if try? submit(changeRequest) wraps another Optional, the discardableResult is
  // not respected. In that case, we may end up with excessive _ = try? submit, which
  // is not desirable in my opinion.
  @discardableResult
  func submit(_: ChangeRequest) throws -> UpdatedObject!
  @discardableResult
  func abort() -> Bool
}
