import Dflat
import SQLite3
import Dispatch

public final class SQLiteDflat: Dflat {

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

  public required init(filePath: String, fileProtectionLevel: FileProtectionLevel, queue: DispatchQueue = DispatchQueue(label: "com.dflat.write", qos: .utility)) {
    self.filePath = filePath
    self.fileProtectionLevel = fileProtectionLevel
    self.queue = queue
    self.readerPool = SQLiteConnectionPool(capacity: 64, filePath: filePath)
    queue.async { [weak self] in
      self?.prepareData()
    }
  }

  public func performChanges(_ anyPool: [Any.Type], changesHandler: @escaping Dflat.ChangesHandler, completionHandler: Dflat.CompletionHandler? = nil) {
    queue.async { [weak self] in
      self?.invokeChangesHandler(anyPool, changesHandler: changesHandler, completionHandler: completionHandler)
    }
  }

  public func fetchFor<T: DflatAtom>(ofType: T.Type) -> DflatQueryBuilder<T> {
    let reader = readerPool.borrow()
    return SQLiteDflatQueryBuilder<T>(reader)
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
    SQLiteDflat.setUpFilePathWithProtectionLevel(filePath: filePath, fileProtectionLevel: fileProtectionLevel)
    writer = SQLiteConnection(filePath: filePath)
    guard let writer = writer else { return }
    sqlite3_busy_timeout(writer.sqlite, 10_000)
    sqlite3_exec(writer.sqlite, "PRAGMA journal_mode=WAL", nil, nil, nil)
    sqlite3_exec(writer.sqlite, "PRAGMA auto_vacuum=incremental", nil, nil, nil)
    sqlite3_exec(writer.sqlite, "PRAGMA incremental_vaccum(2)", nil, nil, nil)
  }

  private func invokeChangesHandler(_ anyPool: [Any.Type], changesHandler: Dflat.ChangesHandler, completionHandler: Dflat.CompletionHandler?) {
    guard let writer = writer else {
      completionHandler?(false)
      return
    }
    let txContext = SQLiteDflatTransactionContext()
    let begin = writer.prepareStatement("BEGIN")
    sqlite3_step(begin)
    changesHandler(txContext)
    let commit = writer.prepareStatement("COMMIT")
    sqlite3_step(commit)
    completionHandler?(false)
  }
}
