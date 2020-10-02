import Dflat
import SQLiteDflat
import SQLite3
import FlatBuffers

// MARK - SQLiteValue for Enumerations

// MARK - Serializer

extension BenchDocV4 {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __title = flatBufferBuilder.create(string: self.title)
    let __tag = self.tag.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __text = self.text.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_BenchDocV4.startBenchDocV4(&flatBufferBuilder)
    zzz_DflatGen_BenchDocV4.add(title: __title, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV4.add(tag: __tag, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV4.add(priority: self.priority, &flatBufferBuilder)
    zzz_DflatGen_BenchDocV4.add(text: __text, &flatBufferBuilder)
    return zzz_DflatGen_BenchDocV4.endBenchDocV4(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == BenchDocV4 {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

// MARK - ChangeRequest

extension BenchDocV4: SQLiteDflat.SQLiteAtom {
  public static var table: String { "benchdocv4" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS benchdocv4 (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))", nil, nil, nil)
  }
  public static func insertIndex(_ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer) -> Bool {
    return true
  }
}

public final class BenchDocV4ChangeRequest: Dflat.ChangeRequest {
  private var _o: BenchDocV4?
  public static var atomType: Any.Type { BenchDocV4.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var title: String
  public var tag: String?
  public var priority: Int32
  public var text: String?
  public init(type: ChangeRequestType) {
    _o = nil
    _type = type
    _rowid = -1
    title = ""
    tag = nil
    priority = 0
    text = nil
  }
  public init(type: ChangeRequestType, _ o: BenchDocV4) {
    _o = o
    _type = type
    _rowid = o._rowid
    title = o.title
    tag = o.tag
    priority = o.priority
    text = o.text
  }
  public static func changeRequest(_ o: BenchDocV4) -> BenchDocV4ChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: BenchDocV4.self, for: key)
    return u.map { BenchDocV4ChangeRequest(type: .update, $0) }
  }
  public static func creationRequest(_ o: BenchDocV4) -> BenchDocV4ChangeRequest {
    let creationRequest = BenchDocV4ChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> BenchDocV4ChangeRequest {
    return BenchDocV4ChangeRequest(type: .creation)
  }
  public static func upsertRequest(_ o: BenchDocV4) -> BenchDocV4ChangeRequest {
    guard let changeRequest = Self.changeRequest(o) else {
      return Self.creationRequest(o)
    }
    return changeRequest
  }
  public static func deletionRequest(_ o: BenchDocV4) -> BenchDocV4ChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: BenchDocV4.self, for: key)
    return u.map { BenchDocV4ChangeRequest(type: .deletion, $0) }
  }
  var _atom: BenchDocV4 {
    let atom = BenchDocV4(title: title, tag: tag, priority: priority, text: text)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      guard let insert = toolbox.connection.prepareStaticStatement("INSERT INTO benchdocv4 (__pk0, p) VALUES (?1, ?2)") else { return nil }
      title.bindSQLite(insert, parameterId: 1)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
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
      guard let update = toolbox.connection.prepareStaticStatement("REPLACE INTO benchdocv4 (__pk0, p, rowid) VALUES (?1, ?2, ?3)") else { return nil }
      title.bindSQLite(update, parameterId: 1)
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 3)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard let deletion = toolbox.connection.prepareStaticStatement("DELETE FROM benchdocv4 WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}
