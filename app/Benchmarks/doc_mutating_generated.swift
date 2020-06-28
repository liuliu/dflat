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
    case .textContent(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .imageContent(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: zzz_DflatGen__BenchDoc.Content {
    switch self {
    case .textContent(_):
      return zzz_DflatGen__BenchDoc.Content.textcontent
    case .imageContent(_):
      return zzz_DflatGen__BenchDoc.Content.imagecontent
    }
  }
}

extension Optional where Wrapped == Content {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: zzz_DflatGen__BenchDoc.Content {
    self.map { $0._type } ?? .none_
  }
}

extension Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer {
    return zzz_DflatGen__BenchDoc.createVec3(x: self.x, y: self.y, z: self.z)
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
    return zzz_DflatGen__BenchDoc.TextContent.createTextContent(&flatBufferBuilder, offsetOfText: __text)
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
    return zzz_DflatGen__BenchDoc.ImageContent.createImageContent(&flatBufferBuilder, vectorOfImages: __vector_images)
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
    let __color = zzz_DflatGen__BenchDoc.Color(rawValue: self.color.rawValue) ?? .red
    let __title = flatBufferBuilder.create(string: self.title)
    let __contentType = self.content._type
    let __content = self.content.to(flatBufferBuilder: &flatBufferBuilder)
    let __tag = self.tag.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    return zzz_DflatGen__BenchDoc.BenchDoc.createBenchDoc(&flatBufferBuilder, structOfPos: __pos, color: __color, offsetOfTitle: __title, contentType: __contentType, offsetOfContent: __content, offsetOfTag: __tag, priority: self.priority)
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
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS benchdoc (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))", nil, nil, nil)
  }
  public static func insertIndex(_ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer) -> Bool {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return false }
    switch field {
    default:
      break
    }
    return true
  }
}

public final class BenchDocChangeRequest: Dflat.ChangeRequest {
  private var _o: BenchDoc?
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
    _o = nil
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
    _o = o
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
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let o = _o else { return nil }
      let atom = self._atom
      guard atom != o else {
        _type = .none
        return .updated(atom)
      }
      guard let update = toolbox.connection.prepareStatement("REPLACE INTO benchdoc (__pk0, p, rowid) VALUES (?1, ?2, ?3)") else { return nil }
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
      guard let deletion = toolbox.connection.prepareStatement("DELETE FROM benchdoc WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}
