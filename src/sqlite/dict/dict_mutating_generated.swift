import Dflat
import FlatBuffers
import Foundation
import SQLite3

// MARK - SQLiteValue for Enumerations

extension ValueType: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension DictItem: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __key = flatBufferBuilder.create(string: self.key)
    let __valueType = zzz_DflatGen_ValueType(rawValue: self.valueType.rawValue) ?? .boolvalue
    let __stringValue =
      self.stringValue.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __vector_codable = flatBufferBuilder.createVector(self.codable)
    let start = zzz_DflatGen_DictItem.startDictItem(&flatBufferBuilder)
    zzz_DflatGen_DictItem.add(key: __key, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(valueType: __valueType, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(boolValue: self.boolValue, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(longValue: self.longValue, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(unsignedLongValue: self.unsignedLongValue, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(floatValue: self.floatValue, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(doubleValue: self.doubleValue, &flatBufferBuilder)
    zzz_DflatGen_DictItem.add(stringValue: __stringValue, &flatBufferBuilder)
    zzz_DflatGen_DictItem.addVectorOf(codable: __vector_codable, &flatBufferBuilder)
    return zzz_DflatGen_DictItem.endDictItem(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == DictItem {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension DictItem {
  public func toData() -> Data {
    var fbb = FlatBufferBuilder()
    let offset = to(flatBufferBuilder: &fbb)
    fbb.finish(offset: offset)
    return fbb.data
  }
}

// MARK - ChangeRequest

public final class DictItemChangeRequest: Dflat.ChangeRequest {
  private var _o: DictItem?
  public static var atomType: Any.Type { DictItem.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var key: String
  public var valueType: ValueType
  public var boolValue: Bool
  public var longValue: Int64
  public var unsignedLongValue: UInt64
  public var floatValue: Float32
  public var doubleValue: Double
  public var stringValue: String?
  public var codable: [UInt8]
  private init(type _type: ChangeRequestType) {
    _o = nil
    self._type = _type
    _rowid = -1
    key = ""
    valueType = .boolValue
    boolValue = false
    longValue = 0
    unsignedLongValue = 0
    floatValue = 0.0
    doubleValue = 0.0
    stringValue = nil
    codable = []
  }
  private init(type _type: ChangeRequestType, _ _o: DictItem) {
    self._o = _o
    self._type = _type
    _rowid = _o._rowid
    key = _o.key
    valueType = _o.valueType
    boolValue = _o.boolValue
    longValue = _o.longValue
    unsignedLongValue = _o.unsignedLongValue
    floatValue = _o.floatValue
    doubleValue = _o.doubleValue
    stringValue = _o.stringValue
    codable = _o.codable
  }
  public static func changeRequest(_ o: DictItem) -> DictItemChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.key])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: DictItem.self, for: key)
    return u.map { DictItemChangeRequest(type: .update, $0) }
  }
  public static func upsertRequest(_ o: DictItem) -> DictItemChangeRequest {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.key])
    guard
      let u = transactionContext.objectRepository.object(
        transactionContext.connection, ofType: DictItem.self, for: key)
    else {
      return Self.creationRequest(o)
    }
    let changeRequest = DictItemChangeRequest(type: .update, o)
    changeRequest._o = u
    changeRequest._rowid = u._rowid
    return changeRequest
  }
  public static func creationRequest(_ o: DictItem) -> DictItemChangeRequest {
    let creationRequest = DictItemChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> DictItemChangeRequest {
    return DictItemChangeRequest(type: .creation)
  }
  public static func deletionRequest(_ o: DictItem) -> DictItemChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.key])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: DictItem.self, for: key)
    return u.map { DictItemChangeRequest(type: .deletion, $0) }
  }
  var _atom: DictItem {
    let atom = DictItem(
      key: key, valueType: valueType, boolValue: boolValue, longValue: longValue,
      unsignedLongValue: unsignedLongValue, floatValue: floatValue, doubleValue: doubleValue,
      stringValue: stringValue, codable: codable)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      guard
        let insert = toolbox.connection.prepareStaticStatement(
          "INSERT INTO dictitem (__pk0, p) VALUES (?1, ?2)")
      else { return nil }
      key.bindSQLite(insert, parameterId: 1)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(
        OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(insert, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      guard SQLITE_DONE == sqlite3_step(insert) else { return nil }
      _rowid = sqlite3_last_insert_rowid(toolbox.connection.sqlite)
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let o = _o else { return nil }
      let atom = self._atom
      guard atom != o else {
        _type = .none
        return .identity(atom)
      }
      guard
        let update = toolbox.connection.prepareStaticStatement(
          "REPLACE INTO dictitem (__pk0, p, rowid) VALUES (?1, ?2, ?3)")
      else { return nil }
      key.bindSQLite(update, parameterId: 1)
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(
        OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 3)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard
        let deletion = toolbox.connection.prepareStaticStatement(
          "DELETE FROM dictitem WHERE rowid=?1")
      else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}
