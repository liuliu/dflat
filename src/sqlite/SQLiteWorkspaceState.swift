import SwiftAtomics

// This is a state shared for a workspace. If later we decide to have multi-writer,
// this need to be re-written in thread-safe fashion.
final class SQLiteWorkspaceState {
  var tableCreated = Set<ObjectIdentifier>()
  var changesTimestamp = AtomicInt64(0)
}
