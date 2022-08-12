import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

public enum ColorV2: Int8, DflatFriendlyValue {
  case red = 0
  case green = 1
  case blue = 2
  public static func < (lhs: ColorV2, rhs: ColorV2) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public final class BenchDocV2: Dflat.Atom, SQLiteDflat.SQLiteAtom, FlatBuffersDecodable, Equatable {
  public static func == (lhs: BenchDocV2, rhs: BenchDocV2) -> Bool {
    guard lhs.color == rhs.color else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.tag == rhs.tag else { return false }
    guard lhs.priority == rhs.priority else { return false }
    guard lhs.text == rhs.text else { return false }
    return true
  }
  public var _rowid: Int64 = -1
  public var _changesTimestamp: Int64 = -1
  public let color: ColorV2
  public let title: String
  public let tag: String?
  public let priority: Int32
  public let text: String?
  public init(
    title: String, color: ColorV2? = .red, tag: String? = nil, priority: Int32? = 0,
    text: String? = nil
  ) {
    self.color = color ?? .red
    self.title = title
    self.tag = tag ?? nil
    self.priority = priority ?? 0
    self.text = text ?? nil
  }
  public init(_ obj: zzz_DflatGen_BenchDocV2) {
    self.color = ColorV2(rawValue: obj.color.rawValue) ?? .red
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
      return Self(zzz_DflatGen_BenchDocV2.getRootAsBenchDocV2(bb: bb))
    }
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_BenchDocV2.getRootAsBenchDocV2(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_BenchDocV2>.verify(
        &verifier, at: 0, of: zzz_DflatGen_BenchDocV2.self)
      return true
    } catch {
      return false
    }
  }
  public static var flatBuffersSchemaVersion: String? {
    return nil
  }
  public static var table: String { "benchdocv2" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else {
      return
    }
    sqlite3_exec(
      sqlite.sqlite,
      "CREATE TABLE IF NOT EXISTS benchdocv2 (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))",
      nil, nil, nil)
  }
  public static func insertIndex(
    _ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer
  ) -> Bool {
    return true
  }
}

#if compiler(>=5.5) && canImport(_Concurrency)
  extension BenchDocV2: @unchecked Sendable {}
#endif
