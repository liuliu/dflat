import Dflat
import SQLite3

private enum TableIndexStatus {
  case unavailable
  case indexed
  case unindexed
}

public final class SQLiteConnection {
  public var sqlite: OpaquePointer?
  fileprivate var tableIndexStatus = [String: [String: TableIndexStatus]]()
  private var stringPool = [String: OpaquePointer]()
  private var staticPool = [UnsafePointer<UInt8>: OpaquePointer]()
  init?(filePath: String, createIfMissing: Bool, readOnly: Bool) {
    // Only 3.22 and above support read-only WAL: https://www.sqlite.org/wal.html#readonly
    var open = false
    if readOnly && sqlite3_libversion_number() >= 3022000 {
      let options = createIfMissing ? SQLITE_OPEN_READONLY | SQLITE_OPEN_CREATE : SQLITE_OPEN_READONLY
      if SQLITE_OK == sqlite3_open_v2(filePath, &sqlite, options, nil) {
        // If this is OK, we are good.
        guard sqlite != nil else { return nil }
        open = true
      }
      // Otherwise, continue to try ReadWrite.
    }
    if !open {
      let options = createIfMissing ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE : SQLITE_OPEN_READWRITE
      guard SQLITE_OK == sqlite3_open_v2(filePath, &sqlite, options, nil) else { return nil }
      guard sqlite != nil else { return nil }
    }
  }
  deinit {
    guard let sqlite = sqlite else { return }
    for prepared in stringPool.values {
      sqlite3_finalize(prepared)
    }
    for prepared in staticPool.values {
      sqlite3_finalize(prepared)
    }
    sqlite3_close(sqlite)
  }
  func close() {
    guard let sqlite = sqlite else { return }
    for prepared in stringPool.values {
      sqlite3_finalize(prepared)
    }
    for prepared in staticPool.values {
      sqlite3_finalize(prepared)
    }
    sqlite3_close(sqlite)
    self.sqlite = nil
  }
  public func prepareStatement(_ statement: String) -> OpaquePointer? {
    guard let sqlite = sqlite else { return nil }
    if let prepared = stringPool[statement] {
      sqlite3_reset(prepared)
      sqlite3_clear_bindings(prepared)
      return prepared
    }
    var prepared: OpaquePointer? = nil
    sqlite3_prepare_v2(sqlite, statement, -1, &prepared, nil)
    if let prepared = prepared {
      stringPool[statement] = prepared
    }
    return prepared
  }
  public func prepareStaticStatement(_ statement: StaticString) -> OpaquePointer? {
    guard let sqlite = sqlite else { return nil }
    let identifier = statement.utf8Start
    if let prepared = staticPool[identifier] {
      sqlite3_reset(prepared)
      sqlite3_clear_bindings(prepared)
      return prepared
    }
    var prepared: OpaquePointer? = nil
    sqlite3_prepare_v2(sqlite, UnsafeRawPointer(identifier).assumingMemoryBound(to: Int8.self), -1, &prepared, nil)
    if let prepared = prepared {
      staticPool[identifier] = prepared
    }
    return prepared
  }
}

extension SQLiteConnection {
  public func clearIndexStatus(for table: String) {
    tableIndexStatus[table] = [String: TableIndexStatus]()
  }
  public func indexSurvey<S: Sequence>(_ existingIndexes: S, table: String) -> IndexSurvey where S.Element == String {
    var indexStatus = tableIndexStatus[table] ?? [String: TableIndexStatus]()
    var indexSurvey = IndexSurvey()
    var savepoint: Bool = false
    defer {
      if savepoint {
        sqlite3_exec(self.sqlite, "RELEASE dflat_idx", nil, nil, nil)
      }
    }
    var maxRowid: Int64? = nil
    for index in existingIndexes {
      if let status = indexStatus[index] {
        switch status {
        case .indexed:
          indexSurvey.full.insert(index)
        case .unindexed:
          indexSurvey.partial.insert(index)
        case .unavailable:
          indexSurvey.unavailable.insert(index)
        }
        continue
      }
      // Otherwise, we need to check the database. First setup a SAVEPOINT so we can view the rowid in a consistent view.
      if !savepoint {
        let sp = self.prepareStaticStatement("SAVEPOINT dflat_idx")
        guard SQLITE_DONE == sqlite3_step(sp) else { return IndexSurvey() }
        savepoint = true
      }
      // Query the main table for max rowid.
      if maxRowid == nil {
        var _maxQuery: OpaquePointer? = nil
        guard SQLITE_OK == sqlite3_prepare_v2(sqlite, "SELECT MAX(rowid) FROM \(table)", -1, &_maxQuery, nil) else {
          // Table doesn't exist at all. Not going to query bit. Just return no up-to-date index.
          return IndexSurvey()
        }
        guard let maxQuery = _maxQuery else {
          // Same thing as above.
          return IndexSurvey()
        }
        if SQLITE_ROW == sqlite3_step(maxQuery) {
          maxRowid = sqlite3_column_int64(maxQuery, 0)
        } else {
          maxRowid = 0
        }
        sqlite3_finalize(maxQuery)
      }
      guard let maxRowid = maxRowid else { fatalError() }
      var _maxQuery: OpaquePointer? = nil
      guard SQLITE_OK == sqlite3_prepare_v2(sqlite, "SELECT MAX(rowid) FROM \(table)__\(index)", -1, &_maxQuery, nil) else {
        // Table doesn't exist. Assuming it is unindexed. This may happen if we had schema upgrade and this is a new
        // index while the old table has 0 rows. For that case, it is indexed. However, this condition may also be
        // some other errors from SQLite, in that case, error on the safe side.
        indexStatus[index] = .unavailable
        indexSurvey.unavailable.insert(index)
        continue
      }
      guard let maxQuery = _maxQuery else {
        indexStatus[index] = .unavailable
        indexSurvey.unavailable.insert(index)
        continue
      }
      if SQLITE_ROW == sqlite3_step(maxQuery) {
        if sqlite3_column_int64(maxQuery, 0) == maxRowid {
          indexStatus[index] = .indexed
          indexSurvey.full.insert(index)
        } else {
          indexStatus[index] = .unindexed
          indexSurvey.partial.insert(index)
        }
      } else {
        if maxRowid == 0 {
          indexStatus[index] = .indexed
          indexSurvey.full.insert(index)
        } else {
          indexStatus[index] = .unindexed
          indexSurvey.partial.insert(index)
        }
      }
      sqlite3_finalize(maxQuery)
    }
    tableIndexStatus[table] = indexStatus
    return indexSurvey
  }
}
