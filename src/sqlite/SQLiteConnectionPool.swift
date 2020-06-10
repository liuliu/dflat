import Dispatch
import SQLite3

final class SQLiteConnectionPool {

  final class Borrowed {
    public let pointee: SQLiteConnection?
    private let pool: SQLiteConnectionPool?
    init(_ pointee: SQLiteConnection?, _ pool: SQLiteConnectionPool?) {
      self.pointee = pointee
      self.pool = pool
    }
    public init(_ pointee: SQLiteConnection?) {
      self.pointee = pointee
      self.pool = nil
    }
    deinit {
      guard let pointee = pointee else { return }
      pool?.add(pointee)
    }
  }

  private var pool = [SQLiteConnection]()
  private let filePath: String
  private let flowControl: DispatchSemaphore
  private let lock: os_unfair_lock_t
  init(capacity: Int, filePath: String) {
    self.filePath = filePath
    flowControl = DispatchSemaphore(value: capacity)
    lock = os_unfair_lock_t.allocate(capacity: 1)
    lock.initialize(to: os_unfair_lock())
  }
  deinit {
    lock.deallocate()
  }
  func borrow() -> Borrowed {
    flowControl.wait()
    os_unfair_lock_lock(lock)
    if let connection = pool.last {
      pool.removeLast()
      os_unfair_lock_unlock(lock)
      return Borrowed(connection, self)
    }
    os_unfair_lock_unlock(lock)
    let pointee = SQLiteConnection(filePath: filePath)
    if pointee == nil {
      flowControl.signal()
    }
    sqlite3_busy_timeout(pointee?.sqlite, 10_000)
    return Borrowed(pointee, self)
  }
  fileprivate func add(_ connection: SQLiteConnection) {
    os_unfair_lock_lock(lock)
    pool.append(connection)
    os_unfair_lock_unlock(lock)
    flowControl.signal()
  }
}
