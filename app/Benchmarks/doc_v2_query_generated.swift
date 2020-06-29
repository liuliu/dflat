import Dflat
import FlatBuffers

extension BenchDocV2 {

  private static func _tr__color(_ table: ByteBuffer) -> (result: ColorV2, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return (ColorV2(rawValue: tr0.color.rawValue)!, false)
  }
  private static func _or__color(_ object: Dflat.Atom) -> (result: ColorV2, unknown: Bool) {
    let or0 = object as! BenchDocV2
    return (or0.color, false)
  }
  static let color: FieldExpr<ColorV2> = FieldExpr(name: "color", primaryKey: false, hasIndex: false, tableReader: _tr__color, objectReader: _or__color)

  private static func _tr__title(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return (tr0.title!, false)
  }
  private static func _or__title(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV2
    return (or0.title, false)
  }
  static let title: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__title, objectReader: _or__title)

  private static func _tr__tag(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    guard let s = tr0.tag else { return ("", true) }
    return (s, false)
  }
  private static func _or__tag(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV2
    guard let s = or0.tag else { return ("", true) }
    return (s, false)
  }
  static let tag: FieldExpr<String> = FieldExpr(name: "tag", primaryKey: false, hasIndex: false, tableReader: _tr__tag, objectReader: _or__tag)

  private static func _tr__priority(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    return (tr0.priority, false)
  }
  private static func _or__priority(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDocV2
    return (or0.priority, false)
  }
  static let priority: FieldExpr<Int32> = FieldExpr(name: "priority", primaryKey: false, hasIndex: false, tableReader: _tr__priority, objectReader: _or__priority)

  private static func _tr__text(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV2.BenchDocV2.getRootAsBenchDocV2(bb: table)
    guard let s = tr0.text else { return ("", true) }
    return (s, false)
  }
  private static func _or__text(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV2
    guard let s = or0.text else { return ("", true) }
    return (s, false)
  }
  static let text: FieldExpr<String> = FieldExpr(name: "text", primaryKey: false, hasIndex: false, tableReader: _tr__text, objectReader: _or__text)
}
