import Dflat
import FlatBuffers

extension BenchDocV2 {

  private static func _tr__f4(_ table: ByteBuffer) -> ColorV2? {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return ColorV2(rawValue: tr0.color.rawValue)!
  }
  private static func _or__f4(_ or0: BenchDocV2) -> ColorV2? {
    return or0.color
  }
  static let color: FieldExpr<ColorV2, BenchDocV2> = FieldExpr(name: "f4", primaryKey: false, hasIndex: false, tableReader: _tr__f4, objectReader: _or__f4)

  private static func _tr__f6(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return tr0.title!
  }
  private static func _or__f6(_ or0: BenchDocV2) -> String? {
    return or0.title
  }
  static let title: FieldExpr<String, BenchDocV2> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    guard let s = tr0.tag else { return nil }
    return s
  }
  private static func _or__f8(_ or0: BenchDocV2) -> String? {
    guard let s = or0.tag else { return nil }
    return s
  }
  static let tag: FieldExpr<String, BenchDocV2> = FieldExpr(name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> Int32? {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return tr0.priority
  }
  private static func _or__f10(_ or0: BenchDocV2) -> Int32? {
    return or0.priority
  }
  static let priority: FieldExpr<Int32, BenchDocV2> = FieldExpr(name: "f10", primaryKey: false, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)

  private static func _tr__f12(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    guard let s = tr0.text else { return nil }
    return s
  }
  private static func _or__f12(_ or0: BenchDocV2) -> String? {
    guard let s = or0.text else { return nil }
    return s
  }
  static let text: FieldExpr<String, BenchDocV2> = FieldExpr(name: "f12", primaryKey: false, hasIndex: false, tableReader: _tr__f12, objectReader: _or__f12)
}
