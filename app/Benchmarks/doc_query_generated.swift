import Dflat
import FlatBuffers

extension BenchDoc {

  struct pos {

  private static func _tr__f4__f0(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return nil }
    return tr1.x
  }
  private static func _or__f4__f0(_ or0: BenchDoc) -> Float32? {
    guard let or1 = or0.pos else { return nil }
    return or1.x
  }
  public static let x: FieldExpr<Float32, BenchDoc> = FieldExpr(name: "f4__f0", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f0, objectReader: _or__f4__f0)

  private static func _tr__f4__f4(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return nil }
    return tr1.y
  }
  private static func _or__f4__f4(_ or0: BenchDoc) -> Float32? {
    guard let or1 = or0.pos else { return nil }
    return or1.y
  }
  public static let y: FieldExpr<Float32, BenchDoc> = FieldExpr(name: "f4__f4", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f4, objectReader: _or__f4__f4)

  private static func _tr__f4__f8(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return nil }
    return tr1.z
  }
  private static func _or__f4__f8(_ or0: BenchDoc) -> Float32? {
    guard let or1 = or0.pos else { return nil }
    return or1.z
  }
  public static let z: FieldExpr<Float32, BenchDoc> = FieldExpr(name: "f4__f8", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f8, objectReader: _or__f4__f8)

  }

  private static func _tr__f6(_ table: ByteBuffer) -> Color? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    return Color(rawValue: tr0.color.rawValue)!
  }
  private static func _or__f6(_ or0: BenchDoc) -> Color? {
    return or0.color
  }
  static let color: FieldExpr<Color, BenchDoc> = FieldExpr(name: "f6", primaryKey: false, hasIndex: false, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    return tr0.title!
  }
  private static func _or__f8(_ or0: BenchDoc) -> String? {
    return or0.title
  }
  static let title: FieldExpr<String, BenchDoc> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  struct content {

  public static func match<T: zzz_DflatGen_Proto__BenchDoc__f12>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32, BenchDoc>, ValueExpr<Int32, BenchDoc>, BenchDoc> {
    return ofType.zzz_match__BenchDoc__f12
  }
  public static func `as`<T: zzz_DflatGen_Proto__BenchDoc__f12>(_ ofType: T.Type) -> T.zzz_AsType__BenchDoc__f12.Type {
    return ofType.zzz_AsType__BenchDoc__f12.self
  }

  private static func _tr__f12__type(_ table: ByteBuffer) -> Int32? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    return Int32(tr0.contentType.rawValue)
  }

  private static func _or__f12__type(_ or0: BenchDoc) -> Int32? {
    guard let o = or0.content else { return nil }
    switch o {
    case .textContent:
      return 1
    case .imageContent:
      return 2
    }
  }
  public static let _type: FieldExpr<Int32, BenchDoc> = FieldExpr(name: "f12__type", primaryKey: false, hasIndex: false, tableReader: _tr__f12__type, objectReader: _or__f12__type)

  }

  private static func _tr__f14(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    guard let s = tr0.tag else { return nil }
    return s
  }
  private static func _or__f14(_ or0: BenchDoc) -> String? {
    guard let s = or0.tag else { return nil }
    return s
  }
  static let tag: FieldExpr<String, BenchDoc> = FieldExpr(name: "f14", primaryKey: false, hasIndex: false, tableReader: _tr__f14, objectReader: _or__f14)

  private static func _tr__f16(_ table: ByteBuffer) -> Int32? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    return tr0.priority
  }
  private static func _or__f16(_ or0: BenchDoc) -> Int32? {
    return or0.priority
  }
  static let priority: FieldExpr<Int32, BenchDoc> = FieldExpr(name: "f16", primaryKey: false, hasIndex: false, tableReader: _tr__f16, objectReader: _or__f16)
}

public protocol zzz_DflatGen_Proto__BenchDoc__f12 {
  associatedtype zzz_AsType__BenchDoc__f12
  static var zzz_match__BenchDoc__f12: EqualToExpr<FieldExpr<Int32, BenchDoc>, ValueExpr<Int32, BenchDoc>, BenchDoc> { get }
}

extension TextContent: zzz_DflatGen_Proto__BenchDoc__f12 {
  public static let zzz_match__BenchDoc__f12: EqualToExpr<FieldExpr<Int32, BenchDoc>, ValueExpr<Int32, BenchDoc>, BenchDoc> = (BenchDoc.content._type == 1)

  public struct zzz_f12__TextContent {

  private static func _tr__f12__u1__f4(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.content(type: zzz_DflatGen_TextContent.self) else { return nil }
    guard let s = tr1.text else { return nil }
    return s
  }
  private static func _or__f12__u1__f4(_ or0: BenchDoc) -> String? {
    guard case let .textContent(or1) = or0.content else { return nil }
    guard let s = or1.text else { return nil }
    return s
  }
  public static let text: FieldExpr<String, BenchDoc> = FieldExpr(name: "f12__u1__f4", primaryKey: false, hasIndex: false, tableReader: _tr__f12__u1__f4, objectReader: _or__f12__u1__f4)
  }
  public typealias zzz_AsType__BenchDoc__f12 = zzz_f12__TextContent

}

extension ImageContent: zzz_DflatGen_Proto__BenchDoc__f12 {
  public static let zzz_match__BenchDoc__f12: EqualToExpr<FieldExpr<Int32, BenchDoc>, ValueExpr<Int32, BenchDoc>, BenchDoc> = (BenchDoc.content._type == 2)

  public struct zzz_f12__ImageContent {
  }
  public typealias zzz_AsType__BenchDoc__f12 = zzz_f12__ImageContent

}
