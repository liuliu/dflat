import Dflat
import SQLite3
import Dispatch
import Foundation

public final class SQLiteWorkspace: Workspace {

  public enum FileProtectionLevel: Int32 {
    case noProtection = 4 // Class D
    case completeFileProtection = 1 // Class A
    case completeFileProtectionUnlessOpen = 2 // Class B
    case completeFileProtectionUntilFirstUserAuthentication = 3 // Class C
  }
  private let filePath: String
  private let fileProtectionLevel: FileProtectionLevel
  private let queue: DispatchQueue
  private var writer: SQLiteConnection?
  private let readerPool: SQLiteConnectionPool
  private let state = SQLiteWorkspaceState()

  public required init(filePath: String, fileProtectionLevel: FileProtectionLevel, queue: DispatchQueue = DispatchQueue(label: "com.dflat.write", qos: .utility)) {
    self.filePath = filePath
    self.fileProtectionLevel = fileProtectionLevel
    self.queue = queue
    self.readerPool = SQLiteConnectionPool(capacity: 64, filePath: filePath)
    queue.async { [weak self] in
      self?.prepareData()
    }
  }

  public func performChanges(_ anyPool: [Any.Type], changesHandler: @escaping Workspace.ChangesHandler, completionHandler: Workspace.CompletionHandler? = nil) {
    queue.async { [weak self] in
      self?.invokeChangesHandler(anyPool, changesHandler: changesHandler, completionHandler: completionHandler)
    }
  }

  static private var snapshot: SQLiteConnectionPool.Borrowed? {
    get {
      Thread.current.threadDictionary["SQLiteSnapshot"] as? SQLiteConnectionPool.Borrowed
    }
    set(newSnapshot) {
      Thread.current.threadDictionary["SQLiteSnapshot"] = newSnapshot
    }
  }

  public func fetchFor<T: Atom>(_ ofType: T.Type) -> QueryBuilder<T> {
    if let txnContext = SQLiteTransactionContext.current {
      precondition(txnContext.contains(ofType: ofType))
      return SQLiteQueryBuilder<T>(txnContext.borrowed, transactionContext: txnContext)
    }
    if let snapshot = Self.snapshot {
      return SQLiteQueryBuilder<T>(snapshot, transactionContext: nil)
    }
    return SQLiteQueryBuilder<T>(readerPool.borrow(), transactionContext: nil)
  }
  
  public func fetchWithinASnapshot<T>(_ closure: () -> T, ofType: T.Type) -> T {
    // If I am in a write transaction, it is a consistent view already.
    if SQLiteTransactionContext.current != nil {
      return closure()
    }
    // Require a consistent snapshot by starting a transaction.
    let reader = readerPool.borrow()
    Self.snapshot = reader
    guard let pointee = reader.pointee else {
      let retval = closure()
      Self.snapshot = nil
      return retval
    }
    let begin = pointee.prepareStatement("BEGIN")
    sqlite3_step(begin)
    let retval = closure()
    let release = pointee.prepareStatement("RELEASE")
    sqlite3_step(release)
    Self.snapshot = nil
    return retval
  }

  static func setUpFilePathWithProtectionLevel(filePath: String, fileProtectionLevel: FileProtectionLevel) {
    #if !targetEnvironment(simulator)
    let fd = open_dprotected_np(filePath, O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0, 0666)
    close(fd)
    let wal = open_dprotected_np(filePath + "-wal", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0, 0666)
    close(wal)
    let shm = open_dprotected_np(filePath + "-shm", O_CREAT | O_WRONLY, fileProtectionLevel.rawValue, 0, 0666)
    close(shm)
    #endif
  }
  
  private func prepareData() {
    dispatchPrecondition(condition: .onQueue(queue))
    // Set the flag before creating the s
    Self.setUpFilePathWithProtectionLevel(filePath: filePath, fileProtectionLevel: fileProtectionLevel)
    writer = SQLiteConnection(filePath: filePath)
    guard let writer = writer else { return }
    sqlite3_busy_timeout(writer.sqlite, 10_000)
    sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
    sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
    sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
  }

  private func invokeChangesHandler(_ anyPool: [Any.Type], changesHandler: Workspace.ChangesHandler, completionHandler: Workspace.CompletionHandler?) {
    guard let writer = writer else {
      completionHandler?(false)
      return
    }
    let txnContext = SQLiteTransactionContext(state, anyPool: anyPool, writer: writer)
    let begin = writer.prepareStatement("BEGIN")
    guard SQLITE_DONE == sqlite3_step(begin) else {
      completionHandler?(false)
      return
    }
    changesHandler(txnContext)
    txnContext.destroy()
    let commit = writer.prepareStatement("COMMIT")
    let status = sqlite3_step(commit)
    if SQLITE_FULL == status {
      let rollback = writer.prepareStatement("ROLLBACK")
      let status = sqlite3_step(rollback)
      precondition(status == SQLITE_DONE)
      completionHandler?(false)
      return
    }
    precondition(status == SQLITE_DONE)
    completionHandler?(true)
  }
}
