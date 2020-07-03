import Dflat
import FlatBuffers

extension BenchDocV2 {

  private static func _tr__f4(_ table: ByteBuffer) -> (result: ColorV2, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return (ColorV2(rawValue: tr0.color.rawValue)!, false)
  }
  private static func _or__f4(_ object: Dflat.Atom) -> (result: ColorV2, unknown: Bool) {
    let or0 = object as! BenchDocV2
    return (or0.color, false)
  }
  static let color: FieldExpr<ColorV2> = FieldExpr(name: "f4", primaryKey: false, hasIndex: false, tableReader: _tr__f4, objectReader: _or__f4)

  private static func _tr__f6(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return (tr0.title!, false)
  }
  private static func _or__f6(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV2
    return (or0.title, false)
  }
  static let title: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    guard let s = tr0.tag else { return ("", true) }
    return (s, false)
  }
  private static func _or__f8(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV2
    guard let s = or0.tag else { return ("", true) }
    return (s, false)
  }
  static let tag: FieldExpr<String> = FieldExpr(name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return (tr0.priority, false)
  }
  private static func _or__f10(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDocV2
    return (or0.priority, false)
  }
  static let priority: FieldExpr<Int32> = FieldExpr(name: "f10", primaryKey: false, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)

  private static func _tr__f12(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    guard let s = tr0.text else { return ("", true) }
    return (s, false)
  }
  private static func _or__f12(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV2
    guard let s = or0.text else { return ("", true) }
    return (s, false)
  }
  static let text: FieldExpr<String> = FieldExpr(name: "f12", primaryKey: false, hasIndex: false, tableReader: _tr__f12, objectReader: _or__f12)
}
