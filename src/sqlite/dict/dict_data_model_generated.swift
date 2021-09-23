import Dflat
import FlatBuffers
import Foundation
import SQLite3

public enum ValueType: Int8, DflatFriendlyValue {
  case boolValue = 0
  case longValue = 1
  case unsignedLongValue = 2
  case floatValue = 3
  case doubleValue = 4
  case stringValue = 5
  case codableValue = 6
  case flatBuffersValue = 7
  public static func < (lhs: ValueType, rhs: ValueType) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public final class DictItem: Dflat.Atom, SQLiteDflat.SQLiteAtom, FlatBuffersDecodable, Equatable {
  public static func == (lhs: DictItem, rhs: DictItem) -> Bool {
    guard lhs.key == rhs.key else { return false }
    guard lhs.namespace == rhs.namespace else { return false }
    guard lhs.valueType == rhs.valueType else { return false }
    guard lhs.boolValue == rhs.boolValue else { return false }
    guard lhs.longValue == rhs.longValue else { return false }
    guard lhs.unsignedLongValue == rhs.unsignedLongValue else { return false }
    guard lhs.floatValue == rhs.floatValue else { return false }
    guard lhs.doubleValue == rhs.doubleValue else { return false }
    guard lhs.stringValue == rhs.stringValue else { return false }
    guard lhs.codable == rhs.codable else { return false }
    return true
  }
  public let key: String
  public let namespace: String
  public let valueType: ValueType
  public let boolValue: Bool
  public let longValue: Int64
  public let unsignedLongValue: UInt64
  public let floatValue: Float32
  public let doubleValue: Double
  public let stringValue: String?
  public let codable: [UInt8]
  public init(key: String, namespace: String, valueType: ValueType? = .boolValue, boolValue: Bool? = false, longValue: Int64? = 0, unsignedLongValue: UInt64? = 0, floatValue: Float32? = 0.0, doubleValue: Double? = 0.0, stringValue: String? = nil, codable: [UInt8]? = []) {
    self.key = key
    self.namespace = namespace
    self.valueType = valueType ?? .boolValue
    self.boolValue = boolValue ?? false
    self.longValue = longValue ?? 0
    self.unsignedLongValue = unsignedLongValue ?? 0
    self.floatValue = floatValue ?? 0.0
    self.doubleValue = doubleValue ?? 0.0
    self.stringValue = stringValue ?? nil
    self.codable = codable ?? []
  }
  public init(_ obj: zzz_DflatGen_DictItem) {
    self.key = obj.key!
    self.namespace = obj.namespace!
    self.valueType = ValueType(rawValue: obj.valueType.rawValue) ?? .boolValue
    self.boolValue = obj.boolValue
    self.longValue = obj.longValue
    self.unsignedLongValue = obj.unsignedLongValue
    self.floatValue = obj.floatValue
    self.doubleValue = obj.doubleValue
    self.stringValue = obj.stringValue
    self.codable = obj.codable
  }
  public static func from(data: Data) -> Self {
    return data.withUnsafeBytes { buffer in
      let bb = ByteBuffer(assumingMemoryBound: UnsafeMutableRawPointer(mutating: buffer.baseAddress!), capacity: buffer.count)
      return Self(zzz_DflatGen_DictItem.getRootAsDictItem(bb: bb))
    }
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_DictItem.getRootAsDictItem(bb: bb))
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_DictItem.getRootAsDictItem(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_DictItem>.verify(&verifier, at: 0, of: zzz_DflatGen_DictItem.self)
      return true
    } catch {
      return false
    }
  }
  public static var table: String { "dictitem_v_dflat_internal__" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS dictitem_v_dflat_internal__ (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, __pk1 TEXT, p BLOB, UNIQUE(__pk0, __pk1))", nil, nil, nil)
  }
  public static func insertIndex(_ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer) -> Bool {
    return true
  }
}
