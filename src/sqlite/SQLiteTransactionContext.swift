import Dflat
import SQLite3
import Foundation

// This is the object per transaction. Even if we support multi-connection later, we will simply
// have one TransactionContext per connection. No thread-safety concerns.
public final class SQLiteTransactionContext: TransactionContext {
  public var objectRepository = SQLiteObjectRepository()
  public var connection: SQLiteConnection {
    toolbox.connection
  }
  private let objectTypes: Set<ObjectIdentifier>
  private let state: SQLiteTableState
  private let toolbox: SQLitePersistenceToolbox
  private var tableCreated = Set<ObjectIdentifier>()
  let changesTimestamp: Int64
  var borrowed: SQLiteConnectionPool.Borrowed {
    SQLiteConnectionPool.Borrowed(pointee: toolbox.connection)
  }
  var aborted: Bool = false
  
  static private(set) public var current: SQLiteTransactionContext? {
    get {
      Thread.current.threadDictionary["SQLiteTxnCurrent"] as? SQLiteTransactionContext
    }
    set (newCurrent) {
      Thread.current.threadDictionary["SQLiteTxnCurrent"] = newCurrent
    }
  }

  init(state: SQLiteTableState, objectTypes: [ObjectIdentifier], changesTimestamp: Int64, connection: SQLiteConnection) {
    var objectTypesSet = Set<ObjectIdentifier>()
    for type in objectTypes {
      objectTypesSet.update(with: type)
    }
    self.state = state
    self.objectTypes = objectTypesSet
    self.toolbox = SQLitePersistenceToolbox(connection: connection)
    self.changesTimestamp = changesTimestamp
    Self.current = self
  }

  func destroy() {
    Self.current = nil
  }

  func contains(ofType: Any.Type) -> Bool {
    return objectTypes.contains(ObjectIdentifier(ofType))
  }
  
  static func transactionalUpdate(toolbox: SQLitePersistenceToolbox, updater: (_: SQLitePersistenceToolbox) -> UpdatedObject?) throws -> UpdatedObject {
    let savepoint = toolbox.connection.prepareStatement("SAVEPOINT dflat_txn")
    guard SQLITE_DONE == sqlite3_step(savepoint) else { throw TransactionError.others }
    let retval = updater(toolbox)
    guard let updatedObject = retval else {
      let errcode = sqlite3_extended_errcode(toolbox.connection.sqlite)
      let rollback = toolbox.connection.prepareStatement("ROLLBACK TO dflat_txn")
      // We cannot handle the situation where the rollback failed.
      let status = sqlite3_step(rollback)
      assert(status == SQLITE_DONE)
      switch errcode {
      case 2067: // SQLITE_CONSTRAINT_UNIQUE:
        throw TransactionError.objectAlreadyExists
      case SQLITE_FULL:
        throw TransactionError.diskFull
      default:
        throw TransactionError.others
      }
    }
    let release = toolbox.connection.prepareStatement("RELEASE dflat_txn")
    let status = sqlite3_step(release)
    if status == SQLITE_FULL {
      // In case of disk full, rollback.
      let rollback = toolbox.connection.prepareStatement("ROLLBACK TO dflat_txn")
      let status = sqlite3_step(rollback)
      assert(status == SQLITE_DONE)
      throw TransactionError.diskFull
    }
    assert(status == SQLITE_DONE)
    return updatedObject
  }

  @discardableResult
  public func submit(_ changeRequest: ChangeRequest) throws -> UpdatedObject {
    let atomType = type(of: changeRequest).atomType
    precondition(contains(ofType: atomType))
    guard !aborted else { throw TransactionError.aborted }
    let atomTypeIdentifier = ObjectIdentifier(atomType)
    if !state.tableCreated.contains(atomTypeIdentifier) {
      (atomType as! SQLiteAtom.Type).setUpSchema(toolbox)
      state.tableCreated.insert(atomTypeIdentifier)
      tableCreated.insert(atomTypeIdentifier)
    }
    do {
      let updatedObject = try Self.transactionalUpdate(toolbox: toolbox) { toolbox in
        changeRequest.commit(toolbox)
      }
      objectRepository.set(updatedObject: updatedObject, ofTypeIdentifier: atomTypeIdentifier)
      return updatedObject
    } catch let error as TransactionError {
      switch error {
        case .diskFull:
          fallthrough
        case .others:
          self.abort()
        default:
          break
      }
      throw error
    }
  }

  @discardableResult
  public func abort() -> Bool {
    guard !aborted else { return false }
    aborted = true
    state.tableCreated.subtract(tableCreated)
    return true
  }
}
