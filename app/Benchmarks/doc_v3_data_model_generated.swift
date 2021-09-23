import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

public final class BenchDocV3: Dflat.Atom, SQLiteDflat.SQLiteAtom, FlatBuffersDecodable, Equatable {
  public static func == (lhs: BenchDocV3, rhs: BenchDocV3) -> Bool {
    guard lhs.title == rhs.title else { return false }
    guard lhs.tag == rhs.tag else { return false }
    guard lhs.priority == rhs.priority else { return false }
    guard lhs.text == rhs.text else { return false }
    return true
  }
  public let title: String
  public let tag: String?
  public let priority: Int32
  public let text: String?
  public init(title: String, tag: String? = nil, priority: Int32? = 0, text: String? = nil) {
    self.title = title
    self.tag = tag ?? nil
    self.priority = priority ?? 0
    self.text = text ?? nil
  }
  public init(_ obj: zzz_DflatGen_BenchDocV3) {
    self.title = obj.title!
    self.tag = obj.tag
    self.priority = obj.priority
    self.text = obj.text
  }
  public static func from(data: Data) -> Self {
    return data.withUnsafeBytes { buffer in
      let bb = ByteBuffer(
        assumingMemoryBound: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
        capacity: buffer.count)
      return Self(zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: bb))
    }
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: bb))
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_BenchDocV3>.verify(
        &verifier, at: 0, of: zzz_DflatGen_BenchDocV3.self)
      return true
    } catch {
      return false
    }
  }
  public static var table: String { "benchdocv3" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else {
      return
    }
    sqlite3_exec(
      sqlite.sqlite,
      "CREATE TABLE IF NOT EXISTS benchdocv3 (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))",
      nil, nil, nil)
  }
  public static func insertIndex(
    _ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer
  ) -> Bool {
    return true
  }
}
