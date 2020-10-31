import Dflat
import FlatBuffers
import SQLiteDflat
import SQLite3

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

public struct Vec3: Equatable {
  public var x: Float32
  public var y: Float32
  public var z: Float32
  public init(x: Float32 = 0.0, y: Float32 = 0.0, z: Float32 = 0.0) {
    self.x = x
    self.y = y
    self.z = z
  }
  public init(_ obj: zzz_DflatGen_Vec3) {
    self.x = obj.x
    self.y = obj.y
    self.z = obj.z
  }
}

public struct TextContent: Equatable {
  public var text: String?
  public init(text: String? = nil) {
    self.text = text
  }
  public init(_ obj: zzz_DflatGen_TextContent) {
    self.text = obj.text
  }
}

public struct ImageContent: Equatable {
  public var images: [String]
  public init(images: [String] = []) {
    self.images = images
  }
  public init(_ obj: zzz_DflatGen_ImageContent) {
    var __images = [String]()
    for i: Int32 in 0..<obj.imagesCount {
      guard let o = obj.images(at: i) else { break }
      __images.append(String(o))
    }
    self.images = __images
  }
}

public final class BenchDoc: Dflat.Atom, SQLiteDflat.SQLiteAtom, Equatable {
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
  public init(title: String, pos: Vec3? = nil, color: Color = .red, content: Content? = nil, tag: String? = nil, priority: Int32 = 0) {
    self.pos = pos
    self.color = color
    self.title = title
    self.content = content
    self.tag = tag
    self.priority = priority
  }
  public init(_ obj: zzz_DflatGen_BenchDoc) {
    self.pos = obj.pos.map { Vec3($0) }
    self.color = Color(rawValue: obj.color.rawValue) ?? .red
    self.title = obj.title!
    switch obj.contentType {
    case .none_:
      self.content = nil
    case .textcontent:
      self.content = obj.content(type: zzz_DflatGen_TextContent.self).map { .textContent(TextContent($0)) }
    case .imagecontent:
      self.content = obj.content(type: zzz_DflatGen_ImageContent.self).map { .imageContent(ImageContent($0)) }
    }
    self.tag = obj.tag
    self.priority = obj.priority
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: bb))
  }
  public static var table: String { "benchdoc" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS benchdoc (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))", nil, nil, nil)
  }
  public static func insertIndex(_ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer) -> Bool {
    return true
  }
}
