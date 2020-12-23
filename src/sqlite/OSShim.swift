import _SQLiteDflatOSShim

#if os(Linux)

  import SwiftGlibc.POSIX.sys.types

  typealias os_unfair_lock_s = pthread_mutex_t

  func os_unfair_lock() -> os_unfair_lock_s {
    var lock = os_unfair_lock_s()
    pthread_mutex_init(&lock, nil)
    return lock
  }

  func os_unfair_lock_lock(_ lock: inout os_unfair_lock_s) {
    pthread_mutex_lock(&lock)
  }

  func os_unfair_lock_unlock(_ lock: inout os_unfair_lock_s) {
    pthread_mutex_unlock(&lock)
  }

#endif

enum ThreadLocalStorage {
  static var transactionContext: SQLiteTransactionContext? {
    get {
      return tls_get_txn_context().map {
        Unmanaged<SQLiteTransactionContext>.fromOpaque($0).takeUnretainedValue()
      }
    }

    set(v) {
      let oldV = tls_get_txn_context()
      guard let v = v else {
        tls_set_txn_context(nil)
        if let oldV = oldV {
          Unmanaged<SQLiteTransactionContext>.fromOpaque(oldV).release()
        }
        return
      }
      tls_set_txn_context(Unmanaged.passRetained(v).toOpaque())
      if let oldV = oldV {
        Unmanaged<SQLiteTransactionContext>.fromOpaque(oldV).release()
      }
    }
  }

  static var snapshot: SQLiteWorkspace.Snapshot? {
    get {
      return tls_get_sqlite_snapshot().map {
        Unmanaged<SQLiteWorkspace.Snapshot>.fromOpaque($0).takeUnretainedValue()
      }
    }

    set(v) {
      let oldV = tls_get_sqlite_snapshot()
      guard let v = v else {
        tls_set_sqlite_snapshot(nil)
        if let oldV = oldV {
          Unmanaged<SQLiteWorkspace.Snapshot>.fromOpaque(oldV).release()
        }
        return
      }
      tls_set_sqlite_snapshot(Unmanaged.passRetained(v).toOpaque())
      if let oldV = oldV {
        Unmanaged<SQLiteWorkspace.Snapshot>.fromOpaque(oldV).release()
      }
    }
  }
}
