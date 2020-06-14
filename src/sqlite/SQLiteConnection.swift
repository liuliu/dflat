import Dflat
import SQLite3

public final class SQLiteConnection {
  public var sqlite: OpaquePointer?
  private var stringPool = [String: OpaquePointer]()
  private var staticPool = [UnsafePointer<UInt8>: OpaquePointer]()
  init?(filePath: String, createIfMissing: Bool) {
    let options = createIfMissing ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE : SQLITE_OPEN_READWRITE
    guard SQLITE_OK == sqlite3_open_v2(filePath, &sqlite, options, nil) else { return nil }
    guard sqlite != nil else { return nil }
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
  public func prepareStatement(_ statement: StaticString) -> OpaquePointer? {
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
