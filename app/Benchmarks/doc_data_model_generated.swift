import Dflat
import FlatBuffers

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
  var x: Float32
  var y: Float32
  var z: Float32
  public init(x: Float32 = 0.0, y: Float32 = 0.0, z: Float32 = 0.0) {
    self.x = x
    self.y = y
    self.z = z
  }
  public init(_ obj: zzz_DflatGen__BenchDoc.Vec3) {
    self.x = obj.x
    self.y = obj.y
    self.z = obj.z
  }
}

public struct TextContent: Equatable {
  var text: String?
  public init(text: String? = nil) {
    self.text = text
  }
  public init(_ obj: zzz_DflatGen__BenchDoc.TextContent) {
    self.text = obj.text
  }
}

public struct ImageContent: Equatable {
  var images: [String]
  public init(images: [String] = []) {
    self.images = images
  }
  public init(_ obj: zzz_DflatGen__BenchDoc.ImageContent) {
    var __images = [String]()
    for i: Int32 in 0..<obj.imagesCount {
      guard let o = obj.images(at: i) else { break }
      __images.append(String(o))
    }
    self.images = __images
  }
}

public final class BenchDoc: Dflat.Atom, Equatable {
  public static func == (lhs: BenchDoc, rhs: BenchDoc) -> Bool {
    guard lhs.pos == rhs.pos else { return false }
    guard lhs.color == rhs.color else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.content == rhs.content else { return false }
    guard lhs.tag == rhs.tag else { return false }
    guard lhs.priority == rhs.priority else { return false }
    return true
  }
  let pos: Vec3?
  let color: Color
  let title: String
  let content: Content?
  let tag: String?
  let priority: Int32
  public init(title: String, pos: Vec3? = nil, color: Color = .red, content: Content? = nil, tag: String? = nil, priority: Int32 = 0) {
    self.pos = pos
    self.color = color
    self.title = title
    self.content = content
    self.tag = tag
    self.priority = priority
  }
  public init(_ obj: zzz_DflatGen__BenchDoc.BenchDoc) {
    self.pos = obj.pos.map { Vec3($0) }
    self.color = Color(rawValue: obj.color.rawValue) ?? .red
    self.title = obj.title!
    switch obj.contentType {
    case .none_:
      self.content = nil
    case .textcontent:
      self.content = obj.content(type: zzz_DflatGen__BenchDoc.TextContent.self).map { .textContent(TextContent($0)) }
    case .imagecontent:
      self.content = obj.content(type: zzz_DflatGen__BenchDoc.ImageContent.self).map { .imageContent(ImageContent($0)) }
    }
    self.tag = obj.tag
    self.priority = obj.priority
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: bb))
  }
}
