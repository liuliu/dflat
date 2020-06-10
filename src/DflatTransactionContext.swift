public protocol DflatTransactionContext {
  func submit(_: DflatChangeRequest) -> Bool
}
