import Dflat
import SQLite3

// MARK - Implement binding for SQLite.

extension Bool: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, self ? 1 : 0)
  }
}
extension Int8: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, Int32(self))
  }
}
extension UInt8: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, Int32(self))
  }
}
extension Int16: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, Int32(self))
  }
}
extension UInt16: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, Int32(self))
  }
}
extension Int32: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, self)
  }
}
extension UInt32: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(query, parameterId, Int32(self))
  }
}
extension Int64: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int64(query, parameterId, self)
  }
}
extension UInt64: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int64(query, parameterId, Int64(self))
  }
}
extension Float: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_double(query, parameterId, Double(self))
  }
}
extension Double: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_double(query, parameterId, self)
  }
}
extension String: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    // This is not ideal, but there isn't a good way to guarentee life-cycle of the String from Swift.
    let SQLITE_TRANSIENT = unsafeBitCast(
      OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
    sqlite3_bind_text(query, parameterId, self, -1, SQLITE_TRANSIENT)
  }
}
