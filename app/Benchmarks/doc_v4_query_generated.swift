import Dflat
import FlatBuffers

extension BenchDocV4 {

  private static func _tr__f4(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDocV4.getRootAsBenchDocV4(bb: table)
    return tr0.title!
  }
  private static func _or__f4(_ or0: BenchDocV4) -> String? {
    return or0.title
  }
  public static let title: FieldExpr<String, BenchDocV4> = FieldExpr(
    name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f4, objectReader: _or__f4)

  private static func _tr__f6(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDocV4.getRootAsBenchDocV4(bb: table)
    guard let s = tr0.tag else { return nil }
    return s
  }
  private static func _or__f6(_ or0: BenchDocV4) -> String? {
    guard let s = or0.tag else { return nil }
    return s
  }
  public static let tag: FieldExpr<String, BenchDocV4> = FieldExpr(
    name: "f6", primaryKey: false, hasIndex: false, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> Int32? {
    let tr0 = zzz_DflatGen_BenchDocV4.getRootAsBenchDocV4(bb: table)
    return tr0.priority
  }
  private static func _or__f8(_ or0: BenchDocV4) -> Int32? {
    return or0.priority
  }
  public static let priority: FieldExpr<Int32, BenchDocV4> = FieldExpr(
    name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDocV4.getRootAsBenchDocV4(bb: table)
    guard let s = tr0.text else { return nil }
    return s
  }
  private static func _or__f10(_ or0: BenchDocV4) -> String? {
    guard let s = or0.text else { return nil }
    return s
  }
  public static let text: FieldExpr<String, BenchDocV4> = FieldExpr(
    name: "f10", primaryKey: false, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)
}
