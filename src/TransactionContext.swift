public protocol TransactionContext {
  @discardableResult
  func submit(_: ChangeRequest) -> Bool
  @discardableResult
  func abort() -> Bool
}
