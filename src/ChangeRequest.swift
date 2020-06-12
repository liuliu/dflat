public protocol PersistenceToolbox {}

public protocol ChangeRequest {
  static var atomType: Any.Type { get }
  // Called to setup basic schema in the persistence storage
  static func setUpSchema(_: PersistenceToolbox)
  // Commit whatever you have in the ChangeRequest to be permanent in persistence storage.
  func commit(_: PersistenceToolbox) -> Bool
}

public enum ChangeRequestType {
  case none // This is useful so that once it is submitted, follow-up submissions can be preconditioned on not being none.
  case creation
  case update
  case deletion
}
