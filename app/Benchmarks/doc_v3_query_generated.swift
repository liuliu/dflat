import Dflat
import FlatBuffers

extension BenchDocV3 {

  private static func _tr__title(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV3.BenchDocV3.getRootAsBenchDocV3(bb: table)
    return (tr0.title!, false)
  }
  private static func _or__title(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV3
    return (or0.title, false)
  }
  static let title: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__title, objectReader: _or__title)

  private static func _tr__tag(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV3.BenchDocV3.getRootAsBenchDocV3(bb: table)
    guard let s = tr0.tag else { return ("", true) }
    return (s, false)
  }
  private static func _or__tag(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV3
    guard let s = or0.tag else { return ("", true) }
    return (s, false)
  }
  static let tag: FieldExpr<String> = FieldExpr(name: "tag", primaryKey: false, hasIndex: false, tableReader: _tr__tag, objectReader: _or__tag)

  private static func _tr__priority(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV3.BenchDocV3.getRootAsBenchDocV3(bb: table)
    return (tr0.priority, false)
  }
  private static func _or__priority(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDocV3
    return (or0.priority, false)
  }
  static let priority: FieldExpr<Int32> = FieldExpr(name: "priority", primaryKey: false, hasIndex: false, tableReader: _tr__priority, objectReader: _or__priority)

  private static func _tr__text(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDocV3.BenchDocV3.getRootAsBenchDocV3(bb: table)
    guard let s = tr0.text else { return ("", true) }
    return (s, false)
  }
  private static func _or__text(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDocV3
    guard let s = or0.text else { return ("", true) }
    return (s, false)
  }
  static let text: FieldExpr<String> = FieldExpr(name: "text", primaryKey: false, hasIndex: false, tableReader: _tr__text, objectReader: _or__text)
}
