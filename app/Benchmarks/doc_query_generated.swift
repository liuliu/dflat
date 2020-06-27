import Dflat
import FlatBuffers

extension BenchDoc {

  struct pos {

  static private func _tr__pos__x(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.x, false)
  }
  static private func _or__pos__x(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.x, false)
  }
  public static let x: FieldExpr<Float32> = FieldExpr(name: "pos__x", primaryKey: false, hasIndex: false, tableReader: _tr__pos__x, objectReader: _or__pos__x)

  static private func _tr__pos__y(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.y, false)
  }
  static private func _or__pos__y(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.y, false)
  }
  public static let y: FieldExpr<Float32> = FieldExpr(name: "pos__y", primaryKey: false, hasIndex: false, tableReader: _tr__pos__y, objectReader: _or__pos__y)

  static private func _tr__pos__z(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.z, false)
  }
  static private func _or__pos__z(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.z, false)
  }
  public static let z: FieldExpr<Float32> = FieldExpr(name: "pos__z", primaryKey: false, hasIndex: false, tableReader: _tr__pos__z, objectReader: _or__pos__z)

  }

  static private func _tr__color(_ table: ByteBuffer) -> (result: Color, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (Color(rawValue: tr0.color.rawValue)!, false)
  }
  static private func _or__color(_ object: Dflat.Atom) -> (result: Color, unknown: Bool) {
    let or0 = object as! BenchDoc
    return (or0.color, false)
  }
  static let color: FieldExpr<Color> = FieldExpr(name: "color", primaryKey: false, hasIndex: false, tableReader: _tr__color, objectReader: _or__color)

  static private func _tr__title(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (tr0.title!, false)
  }
  static private func _or__title(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDoc
    return (or0.title, false)
  }
  static let title: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__title, objectReader: _or__title)

  struct content {

  public static func match<T: BenchDoc__content>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> {
    return ofType.match__BenchDoc__content
  }
  public static func `as`<T: BenchDoc__content>(_ ofType: T.Type) -> T.AsType__BenchDoc__content.Type {
    return ofType.AsType__BenchDoc__content.self
  }

  static private func _tr__content__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (Int32(tr0.contentType.rawValue), false)
  }

  static private func _or__content__type(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let o = or0.content else { return (-1, true) }
    switch o {
    }
  }
  public static let _type: FieldExpr<Int32> = FieldExpr(name: "content__type", primaryKey: false, hasIndex: false, tableReader: _tr__content__type, objectReader: _or__content__type)

  }

  static private func _tr__tag(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    guard let s = tr0.tag else { return ("", true) }
    return (s, false)
  }
  static private func _or__tag(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! BenchDoc
    guard let s = or0.tag else { return ("", true) }
    return (s, false)
  }
  static let tag: FieldExpr<String> = FieldExpr(name: "tag", primaryKey: false, hasIndex: true, tableReader: _tr__tag, objectReader: _or__tag)

  static private func _tr__priority(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = DflatGen__BenchDoc.BenchDoc.getRootAsBenchDoc(bb: table)
    return (tr0.priority, false)
  }
  static private func _or__priority(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! BenchDoc
    return (or0.priority, false)
  }
  static let priority: FieldExpr<Int32> = FieldExpr(name: "priority", primaryKey: false, hasIndex: true, tableReader: _tr__priority, objectReader: _or__priority)
}

public protocol BenchDoc__content {
  associatedtype AsType__BenchDoc__content
  static var match__BenchDoc__content: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> { get }
}
