public protocol PersistenceToolbox {}

public enum UpdatedObject {
  /**
   * A new object inserted. You can subscribe this object immediately.
   */
  case inserted(_: Atom)
  /**
   * An object updated.
   */
  case updated(_: Atom)
  /**
   * An object returned but not updated.
   */
  case identity(_: Atom)
  /**
   * An object deleted. The parameter is irrelevant.
   */
  case deleted(_: Int64)
}

public protocol ChangeRequest {
  static var atomType: Any.Type { get }
  // Commit whatever you have in the ChangeRequest to be permanent in persistence storage.
  func commit(_: PersistenceToolbox) -> UpdatedObject?
}

public enum ChangeRequestType {
  case none // This is useful so that once it is submitted, follow-up submissions can be preconditioned on not being none.
  case creation
  case update
  case deletion
}
