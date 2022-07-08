import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

// MARK - SQLiteValue for Enumerations

extension ColorV2: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension BenchDocV2: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    let __color = zzz_DflatGen_ColorV2(rawValue: self.color.rawValue) ?? .red
    let __title = flatBufferBuilder.create(string: self.title)
    let __tag = self.tag.map { flatBufferBuilder.create(string: $0) } ?? Offset()
    let __text = self.text.map { flatBufferBuilder.create(string: $0) } ?? Offset()
    let start = zzz_DflatGen_BenchDocV2.startBenchDocV2(&flatBufferBuilder)
    zzz_DflatGen_BenchDocV2.add(color: __color, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV2.add(title: __title, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV2.add(tag: __tag, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV2.add(priority: self.priority, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV2.add(text: __text, &flatBufferBuilder)
    return zzz_DflatGen_BenchDocV2.endBenchDocV2(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == BenchDocV2 {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension BenchDocV2 {
  public func toData() -> Data {
    var fbb = FlatBufferBuilder()
    let offset = to(flatBufferBuilder: &fbb)
    fbb.finish(offset: offset)
    return fbb.data
  }
}

// MARK - ChangeRequest

public final class BenchDocV2ChangeRequest: Dflat.ChangeRequest {
  private var _o: BenchDocV2?
  public typealias Element = BenchDocV2
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var color: ColorV2
  public var title: String
  public var tag: String?
  public var priority: Int32
  public var text: String?
  private init(type _type: ChangeRequestType) {
    _o = nil
    self._type = _type
    _rowid = -1
    color = .red
    title = ""
    tag = nil
    priority = 0
    text = nil
  }
  private init(type _type: ChangeRequestType, _ _o: BenchDocV2) {
    self._o = _o
    self._type = _type
    _rowid = _o._rowid
    color = _o.color
    title = _o.title
    tag = _o.tag
    priority = _o.priority
    text = _o.text
  }
  public static func changeRequest(_ o: BenchDocV2) -> BenchDocV2ChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: BenchDocV2.self, for: key)
    return u.map { BenchDocV2ChangeRequest(type: .update, $0) }
  }
  public static func upsertRequest(_ o: BenchDocV2) -> BenchDocV2ChangeRequest {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    guard
      let u = transactionContext.objectRepository.object(
        transactionContext.connection, ofType: BenchDocV2.self, for: key)
    else {
      return Self.creationRequest(o)
    }
    let changeRequest = BenchDocV2ChangeRequest(type: .update, o)
    changeRequest._o = u
    changeRequest._rowid = u._rowid
    return changeRequest
  }
  public static func creationRequest(_ o: BenchDocV2) -> BenchDocV2ChangeRequest {
    let creationRequest = BenchDocV2ChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> BenchDocV2ChangeRequest {
    return BenchDocV2ChangeRequest(type: .creation)
  }
  public static func deletionRequest(_ o: BenchDocV2) -> BenchDocV2ChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: BenchDocV2.self, for: key)
    return u.map { BenchDocV2ChangeRequest(type: .deletion, $0) }
  }
  var _atom: BenchDocV2 {
    let atom = BenchDocV2(title: title, color: color, tag: tag, priority: priority, text: text)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      guard
        let insert = toolbox.connection.prepareStaticStatement(
          "INSERT INTO benchdocv2 (__pk0, p) VALUES (?1, ?2)")
      else { return nil }
      title.bindSQLite(insert, parameterId: 1)
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
          "REPLACE INTO benchdocv2 (__pk0, p, rowid) VALUES (?1, ?2, ?3)")
      else { return nil }
      title.bindSQLite(update, parameterId: 1)
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
          "DELETE FROM benchdocv2 WHERE rowid=?1")
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
