import Dispatch

protocol SQLiteTableSpace: AnyObject {
  var queue: DispatchQueue { get }
  var state: SQLiteTableState { get }
  var resultPublisher: ResultPublisher? { get set }
  func shutdown()
  func connect(_ closure: () -> SQLiteConnection?) -> SQLiteConnection?
  func lock()
  func unlock()
}

final class ConcurrentSQLiteTableSpace: SQLiteTableSpace {
  let queue: DispatchQueue
  let state = SQLiteTableState()
  var resultPublisher: ResultPublisher? = nil
  private var connection: SQLiteConnection? = nil
  private var _shutdown: Bool = false
  private var _lock: os_unfair_lock = os_unfair_lock()
  init(queue: DispatchQueue) {
    self.queue = queue
  }
  func shutdown() {
    _shutdown = true
  }
  func connect(_ closure: () -> SQLiteConnection?) -> SQLiteConnection? {
    guard !_shutdown else { return nil }
    guard connection == nil else { return connection }
    connection = closure()
    return connection
  }
  func lock() {
    os_unfair_lock_lock(&_lock)
  }
  func unlock() {
    os_unfair_lock_unlock(&_lock)
  }
}

final class SerialSQLiteTableSpace: SQLiteTableSpace {
  let queue: DispatchQueue
  let state = SQLiteTableState()
  var resultPublisher: ResultPublisher? = nil
  private var connection: SQLiteConnection? = nil
  private var _shutdown: Bool = false
  init(queue: DispatchQueue) {
    self.queue = queue
  }
  func shutdown() {
    _shutdown = true
  }
  func connect(_ closure: () -> SQLiteConnection?) -> SQLiteConnection? {
    guard !_shutdown else { return nil }
    guard connection == nil else { return connection }
    connection = closure()
    return connection
  }
  func lock() {}
  func unlock() {}
}
