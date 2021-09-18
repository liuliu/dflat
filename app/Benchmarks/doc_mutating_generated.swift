import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

// MARK - SQLiteValue for Enumerations

extension Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension Content: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    case .textContent(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .imageContent(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: zzz_DflatGen_Content {
    switch self {
    case .textContent(_):
      return zzz_DflatGen_Content.textcontent
    case .imageContent(_):
      return zzz_DflatGen_Content.imagecontent
    }
  }
}

extension Optional where Wrapped == Content {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: zzz_DflatGen_Content {
    self.map { $0._type } ?? .none_
  }
}

extension Vec3: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    flatBufferBuilder.create(struct: zzz_DflatGen_Vec3(self))
  }
}

extension zzz_DflatGen_Vec3 {
  init(_ obj: Vec3) {
    self.init(x: obj.x, y: obj.y, z: obj.z)
  }
  init?(_ obj: Vec3?) {
    guard let obj = obj else { return nil }
    self.init(obj)
  }
}

extension TextContent: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __text = self.text.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_TextContent.startTextContent(&flatBufferBuilder)
    zzz_DflatGen_TextContent.add(text: __text, &flatBufferBuilder)
    return zzz_DflatGen_TextContent.endTextContent(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == TextContent {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension ImageContent: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    var __images = [Offset<String>]()
    for i in images {
      __images.append(flatBufferBuilder.create(string: i))
    }
    let __vector_images = flatBufferBuilder.createVector(ofOffsets: __images)
    let start = zzz_DflatGen_ImageContent.startImageContent(&flatBufferBuilder)
    zzz_DflatGen_ImageContent.addVectorOf(images: __vector_images, &flatBufferBuilder)
    return zzz_DflatGen_ImageContent.endImageContent(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == ImageContent {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension BenchDoc: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __color = zzz_DflatGen_Color(rawValue: self.color.rawValue) ?? .red
    let __title = flatBufferBuilder.create(string: self.title)
    let __contentType = self.content._type
    let __content = self.content.to(flatBufferBuilder: &flatBufferBuilder)
    let __tag = self.tag.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_BenchDoc.startBenchDoc(&flatBufferBuilder)
    let __pos = zzz_DflatGen_Vec3(self.pos)
    zzz_DflatGen_BenchDoc.add(pos: __pos, &flatBufferBuilder)
    zzz_DflatGen_BenchDoc.add(color: __color, &flatBufferBuilder)
    zzz_DflatGen_BenchDoc.add(title: __title, &flatBufferBuilder)
    zzz_DflatGen_BenchDoc.add(contentType: __contentType, &flatBufferBuilder)
    zzz_DflatGen_BenchDoc.add(content: __content, &flatBufferBuilder)
    zzz_DflatGen_BenchDoc.add(tag: __tag, &flatBufferBuilder)
    zzz_DflatGen_BenchDoc.add(priority: self.priority, &flatBufferBuilder)
    return zzz_DflatGen_BenchDoc.endBenchDoc(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == BenchDoc {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension BenchDoc {
  public func toData() -> Data {
    var fbb = FlatBufferBuilder()
    let offset = to(flatBufferBuilder: &fbb)
    fbb.finish(offset: offset)
    return fbb.data
  }
}

// MARK - ChangeRequest

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
  private init(type _type: ChangeRequestType) {
    _o = nil
    self._type = _type
    _rowid = -1
    pos = nil
    color = .red
    title = ""
    content = nil
    tag = nil
    priority = 0
  }
  private init(type _type: ChangeRequestType, _ _o: BenchDoc) {
    self._o = _o
    self._type = _type
    _rowid = _o._rowid
    pos = _o.pos
    color = _o.color
    title = _o.title
    content = _o.content
    tag = _o.tag
    priority = _o.priority
  }
  public static func changeRequest(_ o: BenchDoc) -> BenchDocChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: BenchDoc.self, for: key)
    return u.map { BenchDocChangeRequest(type: .update, $0) }
  }
  public static func upsertRequest(_ o: BenchDoc) -> BenchDocChangeRequest {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    guard
      let u = transactionContext.objectRepository.object(
        transactionContext.connection, ofType: BenchDoc.self, for: key)
    else {
      return Self.creationRequest(o)
    }
    let changeRequest = BenchDocChangeRequest(type: .update, o)
    changeRequest._o = u
    changeRequest._rowid = u._rowid
    return changeRequest
  }
  public static func creationRequest(_ o: BenchDoc) -> BenchDocChangeRequest {
    let creationRequest = BenchDocChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> BenchDocChangeRequest {
    return BenchDocChangeRequest(type: .creation)
  }
  public static func deletionRequest(_ o: BenchDoc) -> BenchDocChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.title])
    let u = transactionContext.objectRepository.object(
      transactionContext.connection, ofType: BenchDoc.self, for: key)
    return u.map { BenchDocChangeRequest(type: .deletion, $0) }
  }
  var _atom: BenchDoc {
    let atom = BenchDoc(
      title: title, pos: pos, color: color, content: content, tag: tag, priority: priority)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      guard
        let insert = toolbox.connection.prepareStaticStatement(
          "INSERT INTO benchdoc (__pk0, p) VALUES (?1, ?2)")
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
          "REPLACE INTO benchdoc (__pk0, p, rowid) VALUES (?1, ?2, ?3)")
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
          "DELETE FROM benchdoc WHERE rowid=?1")
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
