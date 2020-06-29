import Dflat
import FlatBuffers

public final class BenchDocV3: Dflat.Atom, Equatable {
  public static func == (lhs: BenchDocV3, rhs: BenchDocV3) -> Bool {
    guard lhs.title == rhs.title else { return false }
    guard lhs.tag == rhs.tag else { return false }
    guard lhs.priority == rhs.priority else { return false }
    guard lhs.text == rhs.text else { return false }
    return true
  }
  let title: String
  let tag: String?
  let priority: Int32
  let text: String?
  public init(title: String, tag: String? = nil, priority: Int32 = 0, text: String? = nil) {
    self.title = title
    self.tag = tag
    self.priority = priority
    self.text = text
  }
  public init(_ obj: zzz_DflatGen__BenchDocV3.BenchDocV3) {
    self.title = obj.title!
    self.tag = obj.tag
    self.priority = obj.priority
    self.text = obj.text
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen__BenchDocV3.BenchDocV3.getRootAsBenchDocV3(bb: bb))
  }
}
