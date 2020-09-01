import Dflat
import FlatBuffers

public extension BenchDocV3 {

  private static func _tr__f4(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: table)
    return tr0.title!
  }
  private static func _or__f4(_ or0: BenchDocV3) -> String? {
    return or0.title
  }
  static let title: FieldExpr<String, BenchDocV3> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f4, objectReader: _or__f4)

  private static func _tr__f6(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: table)
    guard let s = tr0.tag else { return nil }
    return s
  }
  private static func _or__f6(_ or0: BenchDocV3) -> String? {
    guard let s = or0.tag else { return nil }
    return s
  }
  static let tag: FieldExpr<String, BenchDocV3> = FieldExpr(name: "f6", primaryKey: false, hasIndex: false, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> Int32? {
    let tr0 = zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: table)
    return tr0.priority
  }
  private static func _or__f8(_ or0: BenchDocV3) -> Int32? {
    return or0.priority
  }
  static let priority: FieldExpr<Int32, BenchDocV3> = FieldExpr(name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDocV3.getRootAsBenchDocV3(bb: table)
    guard let s = tr0.text else { return nil }
    return s
  }
  private static func _or__f10(_ or0: BenchDocV3) -> String? {
    guard let s = or0.text else { return nil }
    return s
  }
  static let text: FieldExpr<String, BenchDocV3> = FieldExpr(name: "f10", primaryKey: false, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)
}
