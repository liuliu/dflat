import Dflat
import FlatBuffers

extension MyGame.Sample.Monster {

  struct pos {

  private static func _tr__f4__f0(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.x, false)
  }
  private static func _or__f4__f0(_ or0: MyGame.Sample.Monster) -> (result: Float32, unknown: Bool) {
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.x, false)
  }
  public static let x: FieldExpr<Float32, MyGame.Sample.Monster> = FieldExpr(name: "f4__f0", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f0, objectReader: _or__f4__f0)

  private static func _tr__f4__f4(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.y, false)
  }
  private static func _or__f4__f4(_ or0: MyGame.Sample.Monster) -> (result: Float32, unknown: Bool) {
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.y, false)
  }
  public static let y: FieldExpr<Float32, MyGame.Sample.Monster> = FieldExpr(name: "f4__f4", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f4, objectReader: _or__f4__f4)

  private static func _tr__f4__f8(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.z, false)
  }
  private static func _or__f4__f8(_ or0: MyGame.Sample.Monster) -> (result: Float32, unknown: Bool) {
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.z, false)
  }
  public static let z: FieldExpr<Float32, MyGame.Sample.Monster> = FieldExpr(name: "f4__f8", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f8, objectReader: _or__f4__f8)

  }

  private static func _tr__f6(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (tr0.mana, false)
  }
  private static func _or__f6(_ or0: MyGame.Sample.Monster) -> (result: Int16, unknown: Bool) {
    return (or0.mana, false)
  }
  static let mana: FieldExpr<Int16, MyGame.Sample.Monster> = FieldExpr(name: "f6", primaryKey: false, hasIndex: true, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (tr0.hp, false)
  }
  private static func _or__f8(_ or0: MyGame.Sample.Monster) -> (result: Int16, unknown: Bool) {
    return (or0.hp, false)
  }
  static let hp: FieldExpr<Int16, MyGame.Sample.Monster> = FieldExpr(name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (tr0.name!, false)
  }
  private static func _or__f10(_ or0: MyGame.Sample.Monster) -> (result: String, unknown: Bool) {
    return (or0.name, false)
  }
  static let name: FieldExpr<String, MyGame.Sample.Monster> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)

  private static func _tr__f12(_ table: ByteBuffer) -> (result: MyGame.Sample.Color, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (MyGame.Sample.Color(rawValue: tr0.color.rawValue)!, false)
  }
  private static func _or__f12(_ or0: MyGame.Sample.Monster) -> (result: MyGame.Sample.Color, unknown: Bool) {
    return (or0.color, false)
  }
  static let color: FieldExpr<MyGame.Sample.Color, MyGame.Sample.Monster> = FieldExpr(name: "__pk1", primaryKey: true, hasIndex: false, tableReader: _tr__f12, objectReader: _or__f12)

  struct equipped {

  public static func match<T: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32>> {
    return ofType.zzz_match__Monster__f26
  }
  public static func `as`<T: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26>(_ ofType: T.Type) -> T.zzz_AsType__Monster__f26.Type {
    return ofType.zzz_AsType__Monster__f26.self
  }

  private static func _tr__f26__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (Int32(tr0.equippedType.rawValue), false)
  }

  private static func _or__f26__type(_ or0: MyGame.Sample.Monster) -> (result: Int32, unknown: Bool) {
    guard let o = or0.equipped else { return (-1, true) }
    switch o {
    case .weapon:
      return (1, false)
    case .orb:
      return (2, false)
    }
  }
  public static let _type: FieldExpr<Int32, MyGame.Sample.Monster> = FieldExpr(name: "f26__type", primaryKey: false, hasIndex: true, tableReader: _tr__f26__type, objectReader: _or__f26__type)

  }
}

public protocol zzz_DflatGen_Proto__MyGame__Sample__Monster__f26 {
  associatedtype zzz_AsType__Monster__f26
  static var zzz_match__Monster__f26: EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32>> { get }
}

extension MyGame.Sample.Weapon: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26 {
  public static let zzz_match__Monster__f26: EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32>> = (MyGame.Sample.Monster.equipped._type == 1)

  public struct zzz_f26__Weapon {

  private static func _tr__f26__u1__f4(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Weapon.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  private static func _or__f26__u1__f4(_ or0: MyGame.Sample.Monster) -> (result: String, unknown: Bool) {
    guard case let .weapon(or1) = or0.equipped else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String, MyGame.Sample.Monster> = FieldExpr(name: "f26__u1__f4", primaryKey: false, hasIndex: false, tableReader: _tr__f26__u1__f4, objectReader: _or__f26__u1__f4)

  private static func _tr__f26__u1__f6(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Weapon.self) else { return (0, true) }
    return (tr1.damage, false)
  }
  private static func _or__f26__u1__f6(_ or0: MyGame.Sample.Monster) -> (result: Int16, unknown: Bool) {
    guard case let .weapon(or1) = or0.equipped else { return (0, true) }
    return (or1.damage, false)
  }
  public static let damage: FieldExpr<Int16, MyGame.Sample.Monster> = FieldExpr(name: "f26__u1__f6", primaryKey: false, hasIndex: false, tableReader: _tr__f26__u1__f6, objectReader: _or__f26__u1__f6)
  }
  public typealias zzz_AsType__Monster__f26 = zzz_f26__Weapon

}

extension MyGame.Sample.Orb: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26 {
  public static let zzz_match__Monster__f26: EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32>> = (MyGame.Sample.Monster.equipped._type == 2)

  public struct zzz_f26__Orb {

  private static func _tr__f26__u2__f4(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Orb.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  private static func _or__f26__u2__f4(_ or0: MyGame.Sample.Monster) -> (result: String, unknown: Bool) {
    guard case let .orb(or1) = or0.equipped else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String, MyGame.Sample.Monster> = FieldExpr(name: "f26__u2__f4", primaryKey: false, hasIndex: true, tableReader: _tr__f26__u2__f4, objectReader: _or__f26__u2__f4)

  private static func _tr__f26__u2__f6(_ table: ByteBuffer) -> (result: MyGame.Sample.Color, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__Sample__Monster.MyGame.Sample.Orb.self) else { return (.red, true) }
    return (MyGame.Sample.Color(rawValue: tr1.color.rawValue)!, false)
  }
  private static func _or__f26__u2__f6(_ or0: MyGame.Sample.Monster) -> (result: MyGame.Sample.Color, unknown: Bool) {
    guard case let .orb(or1) = or0.equipped else { return (.red, true) }
    return (or1.color, false)
  }
  public static let color: FieldExpr<MyGame.Sample.Color, MyGame.Sample.Monster> = FieldExpr(name: "f26__u2__f6", primaryKey: false, hasIndex: false, tableReader: _tr__f26__u2__f6, objectReader: _or__f26__u2__f6)
  }
  public typealias zzz_AsType__Monster__f26 = zzz_f26__Orb

}
