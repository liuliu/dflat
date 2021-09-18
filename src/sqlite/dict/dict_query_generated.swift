import Dflat
import FlatBuffers

extension DictItem {

  private static func _tr__f4(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return tr0.key!
  }
  private static func _or__f4(_ or0: DictItem) -> String? {
    return or0.key
  }
  public static let key: FieldExpr<String, DictItem> = FieldExpr(
    name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f4, objectReader: _or__f4)

  private static func _tr__f6(_ table: ByteBuffer) -> ValueType? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return ValueType(rawValue: tr0.valueType.rawValue)!
  }
  private static func _or__f6(_ or0: DictItem) -> ValueType? {
    return or0.valueType
  }
  public static let valueType: FieldExpr<ValueType, DictItem> = FieldExpr(
    name: "f6", primaryKey: false, hasIndex: false, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> Bool? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return tr0.boolValue
  }
  private static func _or__f8(_ or0: DictItem) -> Bool? {
    return or0.boolValue
  }
  public static let boolValue: FieldExpr<Bool, DictItem> = FieldExpr(
    name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> Int64? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return tr0.longValue
  }
  private static func _or__f10(_ or0: DictItem) -> Int64? {
    return or0.longValue
  }
  public static let longValue: FieldExpr<Int64, DictItem> = FieldExpr(
    name: "f10", primaryKey: false, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)

  private static func _tr__f12(_ table: ByteBuffer) -> UInt64? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return tr0.unsignedLongValue
  }
  private static func _or__f12(_ or0: DictItem) -> UInt64? {
    return or0.unsignedLongValue
  }
  public static let unsignedLongValue: FieldExpr<UInt64, DictItem> = FieldExpr(
    name: "f12", primaryKey: false, hasIndex: false, tableReader: _tr__f12, objectReader: _or__f12)

  private static func _tr__f14(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return tr0.floatValue
  }
  private static func _or__f14(_ or0: DictItem) -> Float32? {
    return or0.floatValue
  }
  public static let floatValue: FieldExpr<Float32, DictItem> = FieldExpr(
    name: "f14", primaryKey: false, hasIndex: false, tableReader: _tr__f14, objectReader: _or__f14)

  private static func _tr__f16(_ table: ByteBuffer) -> Double? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    return tr0.doubleValue
  }
  private static func _or__f16(_ or0: DictItem) -> Double? {
    return or0.doubleValue
  }
  public static let doubleValue: FieldExpr<Double, DictItem> = FieldExpr(
    name: "f16", primaryKey: false, hasIndex: false, tableReader: _tr__f16, objectReader: _or__f16)

  private static func _tr__f18(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_DictItem.getRootAsDictItem(bb: table)
    guard let s = tr0.stringValue else { return nil }
    return s
  }
  private static func _or__f18(_ or0: DictItem) -> String? {
    guard let s = or0.stringValue else { return nil }
    return s
  }
  public static let stringValue: FieldExpr<String, DictItem> = FieldExpr(
    name: "f18", primaryKey: false, hasIndex: false, tableReader: _tr__f18, objectReader: _or__f18)
}
