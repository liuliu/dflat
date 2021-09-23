import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

public enum Color: Int8, DflatFriendlyValue {
  case red = 0
  case green = 1
  case blue = 2
  public static func < (lhs: Color, rhs: Color) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public enum Content: Equatable {
  case textContent(_: TextContent)
  case imageContent(_: ImageContent)
}

public struct Vec3: Equatable, FlatBuffersDecodable {
  public var x: Float32
  public var y: Float32
  public var z: Float32
  public init(x: Float32? = 0.0, y: Float32? = 0.0, z: Float32? = 0.0) {
    self.x = x ?? 0.0
    self.y = y ?? 0.0
    self.z = z ?? 0.0
  }
  public init(_ obj: zzz_DflatGen_Vec3) {
    self.x = obj.x
    self.y = obj.y
    self.z = obj.z
  }

  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    // Assuming this is the root
    Self(
      bb.read(
        def: zzz_DflatGen_Vec3.self,
        position: Int(bb.read(def: UOffset.self, position: bb.reader)) + bb.reader))
  }

  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_Vec3>.verify(&verifier, at: 0, of: zzz_DflatGen_Vec3.self)
      return true
    } catch {
      return false
    }
  }

  public static var _version: String? {
    return nil
  }
}

public struct TextContent: Equatable, FlatBuffersDecodable {
  public var text: String?
  public init(text: String? = nil) {
    self.text = text ?? nil
  }
  public init(_ obj: zzz_DflatGen_TextContent) {
    self.text = obj.text
  }

  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_TextContent.getRootAsTextContent(bb: bb))
  }

  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_TextContent>.verify(
        &verifier, at: 0, of: zzz_DflatGen_TextContent.self)
      return true
    } catch {
      return false
    }
  }

  public static var _version: String? {
    return nil
  }
}

public struct ImageContent: Equatable, FlatBuffersDecodable {
  public var images: [String]
  public init(images: [String]? = []) {
    self.images = images ?? []
  }
  public init(_ obj: zzz_DflatGen_ImageContent) {
    var __images = [String]()
    for i: Int32 in 0..<obj.imagesCount {
      guard let o = obj.images(at: i) else { break }
      __images.append(String(o))
    }
    self.images = __images
  }

  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_ImageContent.getRootAsImageContent(bb: bb))
  }

  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_ImageContent>.verify(
        &verifier, at: 0, of: zzz_DflatGen_ImageContent.self)
      return true
    } catch {
      return false
    }
  }

  public static var _version: String? {
    return nil
  }
}

public final class BenchDoc: Dflat.Atom, SQLiteDflat.SQLiteAtom, FlatBuffersDecodable, Equatable {
  public static func == (lhs: BenchDoc, rhs: BenchDoc) -> Bool {
    guard lhs.pos == rhs.pos else { return false }
    guard lhs.color == rhs.color else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.content == rhs.content else { return false }
    guard lhs.tag == rhs.tag else { return false }
    guard lhs.priority == rhs.priority else { return false }
    return true
  }
  public let pos: Vec3?
  public let color: Color
  public let title: String
  public let content: Content?
  public let tag: String?
  public let priority: Int32
  public init(
    title: String, pos: Vec3? = nil, color: Color? = .red, content: Content? = nil,
    tag: String? = nil, priority: Int32? = 0
  ) {
    self.pos = pos ?? nil
    self.color = color ?? .red
    self.title = title
    self.content = content ?? nil
    self.tag = tag ?? nil
    self.priority = priority ?? 0
  }
  public init(_ obj: zzz_DflatGen_BenchDoc) {
    self.pos = obj.pos.map { Vec3($0) }
    self.color = Color(rawValue: obj.color.rawValue) ?? .red
    self.title = obj.title!
    switch obj.contentType {
    case .none_:
      self.content = nil
    case .textcontent:
      self.content = obj.content(type: zzz_DflatGen_TextContent.self).map {
        .textContent(TextContent($0))
      }
    case .imagecontent:
      self.content = obj.content(type: zzz_DflatGen_ImageContent.self).map {
        .imageContent(ImageContent($0))
      }
    }
    self.tag = obj.tag
    self.priority = obj.priority
  }
  public static func from(data: Data) -> Self {
    return data.withUnsafeBytes { buffer in
      let bb = ByteBuffer(
        assumingMemoryBound: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
        capacity: buffer.count)
      return Self(zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: bb))
    }
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: bb))
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_BenchDoc>.verify(
        &verifier, at: 0, of: zzz_DflatGen_BenchDoc.self)
      return true
    } catch {
      return false
    }
  }
  public static var _version: String? {
    return nil
  }
  public static var table: String { "benchdoc" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else {
      return
    }
    sqlite3_exec(
      sqlite.sqlite,
      "CREATE TABLE IF NOT EXISTS benchdoc (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))",
      nil, nil, nil)
  }
  public static func insertIndex(
    _ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer
  ) -> Bool {
    return true
  }
}
