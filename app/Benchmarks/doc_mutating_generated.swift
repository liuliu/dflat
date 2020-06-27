import Dflat
import SQLiteDflat
import SQLite3
import FlatBuffers

// MARK - SQLiteValue for Enumerations

extension Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension Content {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    }
  }
  var _type: DflatGen__BenchDoc.Content {
    switch self {
    }
  }
}

extension Optional where Wrapped == Content {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: DflatGen__BenchDoc.Content {
    self.map { $0._type } ?? .none_
  }
}

extension Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer {
    return DflatGen__BenchDoc.createVec3(x: self.x, y: self.y, z: self.z)
  }
}

extension Optional where Wrapped == Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer? {
    self.map { $0.toRawMemory() }
  }
}

extension TextContent {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __text = self.text.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    return DflatGen__BenchDoc.TextContent.createTextContent(&flatBufferBuilder, offsetOfText: __text)
  }
}

extension Optional where Wrapped == TextContent {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension ImageContent {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    var __images = [Offset<String>]()
    for i in images {
      __images.append(flatBufferBuilder.create(string: i))
    }
    let __vector_images = flatBufferBuilder.createVector(ofOffsets: __images)
    return DflatGen__BenchDoc.ImageContent.createImageContent(&flatBufferBuilder, vectorOfImages: __vector_images)
  }
}

extension Optional where Wrapped == ImageContent {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension BenchDoc {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __pos = self.pos.toRawMemory()
    let __color = DflatGen__BenchDoc.Color(rawValue: self.color.rawValue) ?? .red
    let __title = flatBufferBuilder.create(string: self.title)
    let __contentType = self.content._type
    let __content = self.content.to(flatBufferBuilder: &flatBufferBuilder)
    let __tag = self.tag.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    return DflatGen__BenchDoc.BenchDoc.createBenchDoc(&flatBufferBuilder, structOfPos: __pos, color: __color, offsetOfTitle: __title, contentType: __contentType, offsetOfContent: __content, offsetOfTag: __tag, priority: self.priority)
  }
}

extension Optional where Wrapped == BenchDoc {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

// MARK - ChangeRequest

extension BenchDoc: SQLiteDflat.SQLiteAtom {
  public static var table: String { "benchdoc" }
  public static var indexFields: [String] { ["tag", "priority"] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS benchdoc (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS benchdoc__tag (rowid INTEGER PRIMARY KEY, tag TEXT)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE INDEX IF NOT EXISTS index__benchdoc__tag ON benchdoc__tag (tag)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS benchdoc__priority (rowid INTEGER PRIMARY KEY, priority INTEGER)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE INDEX IF NOT EXISTS index__benchdoc__priority ON benchdoc__priority (priority)", nil, nil, nil)
    sqlite.clearIndexStatus(for: Self.table)
  }
  public static func insertIndex(_ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer) -> Bool {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return false }
    switch field {
    case "tag":
      guard let insert = sqlite.prepareStatement("INSERT INTO benchdoc__tag (rowid, tag) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = BenchDoc.tag.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    case "priority":
      guard let insert = sqlite.prepareStatement("INSERT INTO benchdoc__priority (rowid, priority) VALUES (?1, ?2)") else { return false }
      rowid.bindSQLite(insert, parameterId: 1)
      let retval = BenchDoc.priority.evaluate(object: .table(table))
      if retval.unknown {
        sqlite3_bind_null(insert, 2)
      } else {
        retval.result.bindSQLite(insert, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(insert) else { return false }
    default:
      break
    }
    return true
  }
}

public final class BenchDocChangeRequest: Dflat.ChangeRequest {
  public static var atomType: Any.Type { BenchDoc.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var pos: Vec3?
  public var color: Color
  public var title: String
  public var content: Content?
  public var tag: String?
  public var priority: Int32
  public init(type: ChangeRequestType) {
    _type = type
    _rowid = -1
    pos = nil
    color = .red
    title = ""
    content = nil
    tag = nil
    priority = 0
  }
  public init(type: ChangeRequestType, _ o: BenchDoc) {
    _type = type
    _rowid = o._rowid
    pos = o.pos
    color = o.color
    title = o.title
    content = o.content
    tag = o.tag
    priority = o.priority
  }
  public static func changeRequest(_ o: BenchDoc) -> BenchDocChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: BenchDoc.self, for: key)
    return u.map { BenchDocChangeRequest(type: .update, $0) }
  }
  public static func creationRequest(_ o: BenchDoc) -> BenchDocChangeRequest {
    let creationRequest = BenchDocChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> BenchDocChangeRequest {
    return BenchDocChangeRequest(type: .creation)
  }
  public static func upsertRequest(_ o: BenchDoc) -> BenchDocChangeRequest {
    guard let changeRequest = Self.changeRequest(o) else {
      return Self.creationRequest(o)
    }
    return changeRequest
  }
  public static func deletionRequest(_ o: BenchDoc) -> BenchDocChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: BenchDoc.self, for: key)
    return u.map { BenchDocChangeRequest(type: .deletion, $0) }
  }
  var _atom: BenchDoc {
    let atom = BenchDoc(title: title, pos: pos, color: color, content: content, tag: tag, priority: priority)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    let indexSurvey = toolbox.connection.indexSurvey(BenchDoc.indexFields, table: BenchDoc.table)
    switch _type {
    case .creation:
      guard let insert = toolbox.connection.prepareStatement("INSERT INTO benchdoc (__pk0, p) VALUES (?1, ?2)") else { return nil }
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
      if indexSurvey.full.contains("tag") {
        guard let i0 = toolbox.connection.prepareStatement("INSERT INTO benchdoc__tag (rowid, tag) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i0, parameterId: 1)
        let r0 = BenchDoc.tag.evaluate(object: .object(atom))
        if r0.unknown {
          sqlite3_bind_null(i0, 2)
        } else {
          r0.result.bindSQLite(i0, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i0) else { return nil }
      }
      if indexSurvey.full.contains("priority") {
        guard let i1 = toolbox.connection.prepareStatement("INSERT INTO benchdoc__priority (rowid, priority) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i1, parameterId: 1)
        let r1 = BenchDoc.priority.evaluate(object: .object(atom))
        if r1.unknown {
          sqlite3_bind_null(i1, 2)
        } else {
          r1.result.bindSQLite(i1, parameterId: 2)
        }
        guard SQLITE_DONE == sqlite3_step(i1) else { return nil }
      }
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let update = toolbox.connection.prepareStatement("UPDATE benchdoc SET __pk0=?1, p=?2 WHERE rowid=?3 LIMIT 1") else { return nil }
      title.bindSQLite(update, parameterId: 1)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 3)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      if indexSurvey.full.contains("tag") {
        guard let u0 = toolbox.connection.prepareStatement("UPDATE benchdoc__tag SET tag=?1 WHERE rowid=?2 LIMIT 1") else { return nil }
        _rowid.bindSQLite(u0, parameterId: 2)
        let r0 = BenchDoc.tag.evaluate(object: .object(atom))
        if r0.unknown {
          sqlite3_bind_null(u0, 1)
        } else {
          r0.result.bindSQLite(u0, parameterId: 1)
        }
        guard SQLITE_DONE == sqlite3_step(u0) else { return nil }
      }
      if indexSurvey.full.contains("priority") {
        guard let u1 = toolbox.connection.prepareStatement("UPDATE benchdoc__priority SET priority=?1 WHERE rowid=?2 LIMIT 1") else { return nil }
        _rowid.bindSQLite(u1, parameterId: 2)
        let r1 = BenchDoc.priority.evaluate(object: .object(atom))
        if r1.unknown {
          sqlite3_bind_null(u1, 1)
        } else {
          r1.result.bindSQLite(u1, parameterId: 1)
        }
        guard SQLITE_DONE == sqlite3_step(u1) else { return nil }
      }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard let deletion = toolbox.connection.prepareStatement("DELETE FROM benchdoc WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      if let d0 = toolbox.connection.prepareStatement("DELETE FROM benchdoc__tag WHERE rowid=?1") {
        _rowid.bindSQLite(d0, parameterId: 1)
        sqlite3_step(d0)
      }
      if let d1 = toolbox.connection.prepareStatement("DELETE FROM benchdoc__priority WHERE rowid=?1") {
        _rowid.bindSQLite(d1, parameterId: 1)
        sqlite3_step(d1)
      }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}
