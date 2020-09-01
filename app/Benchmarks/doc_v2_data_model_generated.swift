import Dflat
import FlatBuffers

public enum ColorV2: Int8, DflatFriendlyValue {
  case red = 0
  case green = 1
  case blue = 2
  public static func < (lhs: ColorV2, rhs: ColorV2) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public final class BenchDocV2: Dflat.Atom, Equatable {
  public static func == (lhs: BenchDocV2, rhs: BenchDocV2) -> Bool {
    guard lhs.color == rhs.color else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.tag == rhs.tag else { return false }
    guard lhs.priority == rhs.priority else { return false }
    guard lhs.text == rhs.text else { return false }
    return true
  }
  public let color: ColorV2
  public let title: String
  public let tag: String?
  public let priority: Int32
  public let text: String?
  public init(title: String, color: ColorV2 = .red, tag: String? = nil, priority: Int32 = 0, text: String? = nil) {
    self.color = color
    self.title = title
    self.tag = tag
    self.priority = priority
    self.text = text
  }
  public init(_ obj: zzz_DflatGen_BenchDocV2) {
    self.color = ColorV2(rawValue: obj.color.rawValue) ?? .red
    self.title = obj.title!
    self.tag = obj.tag
    self.priority = obj.priority
    self.text = obj.text
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDocV2.getRootAsBenchDocV2(bb: bb))
  }
}
