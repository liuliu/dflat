public protocol SchemaSetUpper {}

public protocol ChangeRequest {
  static var atomType: Any.Type { get }
  static func setUpSchema(_: SchemaSetUpper)
}

public enum ChangeRequestType {
  case none // This is useful so that once it is submitted, follow-up submissions can be preconditioned on not being none.
  case creation
  case update
  case deletion
}
