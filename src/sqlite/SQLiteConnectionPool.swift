import Dispatch
import SQLite3

final class SQLiteConnectionPool {

  struct Borrowed {
    let pointee: SQLiteConnection?
    private let pool: SQLiteConnectionPool?
    init(pointee: SQLiteConnection?, pool: SQLiteConnectionPool? = nil) {
      self.pointee = pointee
      self.pool = pool
    }
    func `return`() {
      guard let pointee = pointee else { return }
      pool?.add(pointee)
    }
  }

  private var pool = [SQLiteConnection]()
  private let filePath: String
  private let flowControl: DispatchSemaphore
  private let capacity: Int
  private var lock: os_unfair_lock_s
  private var shutdown: Bool
  init(capacity: Int, filePath: String) {
    self.capacity = capacity
    self.filePath = filePath
    flowControl = DispatchSemaphore(value: capacity)
    lock = os_unfair_lock()
    shutdown = false
  }
  func drain() {
    os_unfair_lock_lock(&lock)
    shutdown = true
    os_unfair_lock_unlock(&lock)
    // Simply wait out any and every connection we give out.
    for _ in 0..<capacity {
      flowControl.wait()
    }
  }
  func borrow() -> Borrowed {
    flowControl.wait()
    os_unfair_lock_lock(&lock)
    // If we shutdown, give out nil.
    if shutdown {
      os_unfair_lock_unlock(&lock)
      flowControl.signal()
      return Borrowed(pointee: nil, pool: nil)
    }
    // We are going to give out something
    if let connection = pool.last {
      pool.removeLast()
      os_unfair_lock_unlock(&lock)
      return Borrowed(pointee: connection, pool: self)
    }
    os_unfair_lock_unlock(&lock)
    let pointee = SQLiteConnection(filePath: filePath, createIfMissing: false, readOnly: true)
    if pointee == nil { // This is unusual, but we give out a nil.
      os_unfair_lock_lock(&lock)
      os_unfair_lock_unlock(&lock)
      flowControl.signal()
      return Borrowed(pointee: pointee, pool: nil)
    }
    sqlite3_busy_timeout(pointee?.sqlite, 10_000)
    return Borrowed(pointee: pointee, pool: self)
  }
  fileprivate func add(_ connection: SQLiteConnection) {
    os_unfair_lock_lock(&lock)
    pool.append(connection)
    os_unfair_lock_unlock(&lock)
    flowControl.signal()
  }
}
