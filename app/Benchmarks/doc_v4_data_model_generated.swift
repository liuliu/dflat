import Dflat
import FlatBuffers

public final class BenchDocV4: Dflat.Atom, Equatable {
  public static func == (lhs: BenchDocV4, rhs: BenchDocV4) -> Bool {
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
  public init(_ obj: zzz_DflatGen__BenchDocV4.BenchDocV4) {
    self.title = obj.title!
    self.tag = obj.tag
    self.priority = obj.priority
    self.text = obj.text
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen__BenchDocV4.BenchDocV4.getRootAsBenchDocV4(bb: bb))
  }
}
