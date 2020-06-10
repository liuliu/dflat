import Dflat
import SQLite3

public protocol SQLiteValue: DflatFriendlyValue {
  func bindSQLite(_ clause: OpaquePointer, parameterId: Int32)
}

extension ValueExpr: SQLiteExpr where T: SQLiteValue {
  public func buildWhereClause(availableIndexes: Set<String>, clause: inout String, parameterCount: inout Int32) {
    parameterCount += 1
    let parameterId = parameterCount
    clause.append("?\(parameterId)")
  }
  public func bindWhereClause(availableIndexes: Set<String>, clause: OpaquePointer, parameterCount: inout Int32) {
    parameterCount += 1
    let parameterId = parameterCount
    value.bindSQLite(clause, parameterId: parameterId)
  }
}

// MARK - Implement binding for SQLite.

extension Bool: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, self ? 1 : 0)
  }
}
extension Int8: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, Int32(self))
  }
}
extension UInt8: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, Int32(self))
  }
}
extension Int16: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, Int32(self))
  }
}
extension UInt16: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, Int32(self))
  }
}
extension Int32: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, self)
  }
}
extension UInt32: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int(clause, parameterId, Int32(self))
  }
}
extension Int64: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int64(clause, parameterId, self)
  }
}
extension UInt64: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_int64(clause, parameterId, Int64(self))
  }
}
extension Float: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_double(clause, parameterId, Double(self))
  }
}
extension Double: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    sqlite3_bind_double(clause, parameterId, self)
  }
}
extension String: SQLiteValue {
  public func bindSQLite(_ clause: OpaquePointer, parameterId: Int32) {
    // This is not ideal, but there isn't a good way to guarentee life-cycle of the String from Swift.
    let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
    sqlite3_bind_text(clause, parameterId, self, -1, SQLITE_TRANSIENT)
  }
}
