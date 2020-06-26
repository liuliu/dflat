import SwiftAtomics
import Dispatch

// This is a state shared for a workspace.
final class SQLiteWorkspaceState {
  private var lock = os_unfair_lock()
  private var tableTimestamps = [ObjectIdentifier: Int64]()
  var changesTimestamp = AtomicInt64(0)

  func serial<T>(_ closure: () -> T) -> T {
    os_unfair_lock_lock(&lock)
    let retval = closure()
    os_unfair_lock_unlock(&lock)
    return retval
  }

  func setTableTimestamp<S: Sequence>(_ timestamp: Int64, for identifiers: S) where S.Element == ObjectIdentifier {
    os_unfair_lock_lock(&lock)
    for identifier in identifiers {
      tableTimestamps[identifier] = timestamp
    }
    os_unfair_lock_unlock(&lock)
  }

  func tableTimestamp(for identifier: ObjectIdentifier) -> Int64 {
    os_unfair_lock_lock(&lock)
    let tableTimestamp = tableTimestamps[identifier] ?? -1
    os_unfair_lock_unlock(&lock)
    return tableTimestamp
  }
}
