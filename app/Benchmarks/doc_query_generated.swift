import Dflat
import FlatBuffers

extension BenchDoc {

  struct pos {

  private static func _tr__pos__x(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.x, false)
  }
  private static func _or__pos__x(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.x, false)
  }
  public static let x: FieldExpr<Float32> = FieldExpr(name: "pos__x", primaryKey: false, hasIndex: false, tableReader: _tr__pos__x, objectReader: _or__pos__x)

  private static func _tr__pos__y(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.y, false)
  }
  private static func _or__pos__y(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.y, false)
  }
  public static let y: FieldExpr<Float32> = FieldExpr(name: "pos__y", primaryKey: false, hasIndex: false, tableReader: _tr__pos__y, objectReader: _or__pos__y)

  private static func _tr__pos__z(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.z, false)
  }
  private static func _or__pos__z(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.z, false)
  }
  public static let z: FieldExpr<Float32> = FieldExpr(name: "pos__z", primaryKey: false, hasIndex: false, tableReader: _tr__pos__z, objectReader: _or__pos__z)

  }

  private static func _tr__color(_ table: ByteBuffer) -> (result: Color, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (Color(rawValue: tr0.color.rawValue)!, false)
  }
  private static func _or__color(_ object: Dflat.Atom) -> (result: Color, unknown: Bool) {
    let or0 = object as! BenchDoc
    return (or0.color, false)
  }
  static let color: FieldExpr<Color> = FieldExpr(name: "color", primaryKey: false, hasIndex: false, tableReader: _tr__color, objectReader: _or__color)

  private static func _tr__title(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (tr0.title!, false)
  }
  private static func _or__title(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDoc
    return (or0.title, false)
  }
  static let title: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__title, objectReader: _or__title)

  struct content {

  public static func match<T: zzz_DflatGen_Proto__BenchDoc__content>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> {
    return ofType.zzz_match__BenchDoc__content
  }
  public static func `as`<T: zzz_DflatGen_Proto__BenchDoc__content>(_ ofType: T.Type) -> T.zzz_AsType__BenchDoc__content.Type {
    return ofType.zzz_AsType__BenchDoc__content.self
  }

  private static func _tr__content__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (Int32(tr0.contentType.rawValue), false)
  }

  private static func _or__content__type(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let o = or0.content else { return (-1, true) }
    switch o {
    case .textContent:
      return (1, false)
    case .imageContent:
      return (2, false)
    }
  }
  public static let _type: FieldExpr<Int32> = FieldExpr(name: "content__type", primaryKey: false, hasIndex: false, tableReader: _tr__content__type, objectReader: _or__content__type)

  }

  private static func _tr__tag(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let s = tr0.tag else { return ("", true) }
    return (s, false)
  }
  private static func _or__tag(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let s = or0.tag else { return ("", true) }
    return (s, false)
  }
  static let tag: FieldExpr<String> = FieldExpr(name: "tag", primaryKey: false, hasIndex: false, tableReader: _tr__tag, objectReader: _or__tag)

  private static func _tr__priority(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (tr0.priority, false)
  }
  private static func _or__priority(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDoc
    return (or0.priority, false)
  }
  static let priority: FieldExpr<Int32> = FieldExpr(name: "priority", primaryKey: false, hasIndex: false, tableReader: _tr__priority, objectReader: _or__priority)
}

public protocol zzz_DflatGen_Proto__BenchDoc__content {
  associatedtype zzz_AsType__BenchDoc__content
  static var zzz_match__BenchDoc__content: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> { get }
}

extension TextContent: zzz_DflatGen_Proto__BenchDoc__content {
  public static let zzz_match__BenchDoc__content: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (BenchDoc.content._type == 1)

  public struct zzz_content__TextContent {

  private static func _tr__content__TextContent__text(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.content(type: zzz_DflatGen__BenchDoc.TextContent.self) else { return ("", true) }
    guard let s = tr1.text else { return ("", true) }
    return (s, false)
  }
  private static func _or__content__TextContent__text(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard case let .textContent(or1) = or0.content else { return ("", true) }
    guard let s = or1.text else { return ("", true) }
    return (s, false)
  }
  public static let text: FieldExpr<String> = FieldExpr(name: "content__TextContent__text", primaryKey: false, hasIndex: false, tableReader: _tr__content__TextContent__text, objectReader: _or__content__TextContent__text)
  }
  public typealias zzz_AsType__BenchDoc__content = zzz_content__TextContent

}

extension ImageContent: zzz_DflatGen_Proto__BenchDoc__content {
  public static let zzz_match__BenchDoc__content: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (BenchDoc.content._type == 2)

  public struct zzz_content__ImageContent {
  }
  public typealias zzz_AsType__BenchDoc__content = zzz_content__ImageContent

}
