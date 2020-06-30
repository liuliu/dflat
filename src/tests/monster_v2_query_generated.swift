import Dflat
import FlatBuffers

extension MyGame.SampleV2.Monster {

  struct pos {

  private static func _tr__pos__x(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.x, false)
  }
  private static func _or__pos__x(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.x, false)
  }
  public static let x: FieldExpr<Float32> = FieldExpr(name: "pos__x", primaryKey: false, hasIndex: false, tableReader: _tr__pos__x, objectReader: _or__pos__x)

  private static func _tr__pos__y(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.y, false)
  }
  private static func _or__pos__y(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.y, false)
  }
  public static let y: FieldExpr<Float32> = FieldExpr(name: "pos__y", primaryKey: false, hasIndex: false, tableReader: _tr__pos__y, objectReader: _or__pos__y)

  private static func _tr__pos__z(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.z, false)
  }
  private static func _or__pos__z(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.z, false)
  }
  public static let z: FieldExpr<Float32> = FieldExpr(name: "pos__z", primaryKey: false, hasIndex: false, tableReader: _tr__pos__z, objectReader: _or__pos__z)

  }

  private static func _tr__mana(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (tr0.mana, false)
  }
  private static func _or__mana(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.mana, false)
  }
  static let mana: FieldExpr<Int16> = FieldExpr(name: "mana", primaryKey: false, hasIndex: true, tableReader: _tr__mana, objectReader: _or__mana)

  private static func _tr__hp(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (tr0.hp, false)
  }
  private static func _or__hp(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.hp, false)
  }
  static let hp: FieldExpr<Int16> = FieldExpr(name: "hp", primaryKey: false, hasIndex: true, tableReader: _tr__hp, objectReader: _or__hp)

  private static func _tr__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (tr0.name!, false)
  }
  private static func _or__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.name, false)
  }
  static let name: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__name, objectReader: _or__name)

  private static func _tr__color(_ table: ByteBuffer) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (MyGame.SampleV2.Color(rawValue: tr0.color.rawValue)!, false)
  }
  private static func _or__color(_ object: Dflat.Atom) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.color, false)
  }
  static let color: FieldExpr<MyGame.SampleV2.Color> = FieldExpr(name: "__pk1", primaryKey: true, hasIndex: false, tableReader: _tr__color, objectReader: _or__color)

  struct equipped {

  public static func match<T: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__equipped>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> {
    return ofType.zzz_match__Monster__equipped
  }
  public static func `as`<T: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__equipped>(_ ofType: T.Type) -> T.zzz_AsType__Monster__equipped.Type {
    return ofType.zzz_AsType__Monster__equipped.self
  }

  private static func _tr__equipped__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (Int32(tr0.equippedType.rawValue), false)
  }

  private static func _or__equipped__type(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let o = or0.equipped else { return (-1, true) }
    switch o {
    case .weapon:
      return (1, false)
    case .orb:
      return (2, false)
    case .empty:
      return (3, false)
    }
  }
  public static let _type: FieldExpr<Int32> = FieldExpr(name: "equipped__type", primaryKey: false, hasIndex: true, tableReader: _tr__equipped__type, objectReader: _or__equipped__type)

  }

  struct wear {

  public static func match<T: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__wear>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> {
    return ofType.zzz_match__Monster__wear
  }
  public static func `as`<T: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__wear>(_ ofType: T.Type) -> T.zzz_AsType__Monster__wear.Type {
    return ofType.zzz_AsType__Monster__wear.self
  }

  private static func _tr__wear__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (Int32(tr0.wearType.rawValue), false)
  }

  private static func _or__wear__type(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let o = or0.wear else { return (-1, true) }
    switch o {
    case .weapon:
      return (1, false)
    case .orb:
      return (2, false)
    case .empty:
      return (3, false)
    }
  }
  public static let _type: FieldExpr<Int32> = FieldExpr(name: "wear__type", primaryKey: false, hasIndex: false, tableReader: _tr__wear__type, objectReader: _or__wear__type)

  }
}

public protocol zzz_DflatGen_Proto__MyGame__SampleV2__Monster__equipped {
  associatedtype zzz_AsType__Monster__equipped
  static var zzz_match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> { get }
}

extension MyGame.SampleV2.Weapon: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__equipped {
  public static let zzz_match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.equipped._type == 1)

  public struct zzz_equipped__Weapon {

  private static func _tr__equipped__Weapon__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  private static func _or__equipped__Weapon__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.equipped else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "equipped__Weapon__name", primaryKey: false, hasIndex: false, tableReader: _tr__equipped__Weapon__name, objectReader: _or__equipped__Weapon__name)

  private static func _tr__equipped__Weapon__damage(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return (0, true) }
    return (tr1.damage, false)
  }
  private static func _or__equipped__Weapon__damage(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.equipped else { return (0, true) }
    return (or1.damage, false)
  }
  public static let damage: FieldExpr<Int16> = FieldExpr(name: "equipped__Weapon__damage", primaryKey: false, hasIndex: false, tableReader: _tr__equipped__Weapon__damage, objectReader: _or__equipped__Weapon__damage)
  }
  public typealias zzz_AsType__Monster__equipped = zzz_equipped__Weapon

}

extension MyGame.SampleV2.Orb: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__equipped {
  public static let zzz_match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.equipped._type == 2)

  public struct zzz_equipped__Orb {

  private static func _tr__equipped__Orb__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  private static func _or__equipped__Orb__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.equipped else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "equipped__Orb__name", primaryKey: false, hasIndex: true, tableReader: _tr__equipped__Orb__name, objectReader: _or__equipped__Orb__name)

  private static func _tr__equipped__Orb__color(_ table: ByteBuffer) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return (.red, true) }
    return (MyGame.SampleV2.Color(rawValue: tr1.color.rawValue)!, false)
  }
  private static func _or__equipped__Orb__color(_ object: Dflat.Atom) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.equipped else { return (.red, true) }
    return (or1.color, false)
  }
  public static let color: FieldExpr<MyGame.SampleV2.Color> = FieldExpr(name: "equipped__Orb__color", primaryKey: false, hasIndex: false, tableReader: _tr__equipped__Orb__color, objectReader: _or__equipped__Orb__color)
  }
  public typealias zzz_AsType__Monster__equipped = zzz_equipped__Orb

}

extension MyGame.SampleV2.Empty: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__equipped {
  public static let zzz_match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.equipped._type == 3)

  public struct zzz_equipped__Empty {
  }
  public typealias zzz_AsType__Monster__equipped = zzz_equipped__Empty

}

public protocol zzz_DflatGen_Proto__MyGame__SampleV2__Monster__wear {
  associatedtype zzz_AsType__Monster__wear
  static var zzz_match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> { get }
}

extension MyGame.SampleV2.Weapon: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__wear {
  public static let zzz_match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.wear._type == 1)

  public struct zzz_wear__Weapon {

  private static func _tr__wear__Weapon__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  private static func _or__wear__Weapon__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.wear else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "wear__Weapon__name", primaryKey: false, hasIndex: false, tableReader: _tr__wear__Weapon__name, objectReader: _or__wear__Weapon__name)

  private static func _tr__wear__Weapon__damage(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return (0, true) }
    return (tr1.damage, false)
  }
  private static func _or__wear__Weapon__damage(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.wear else { return (0, true) }
    return (or1.damage, false)
  }
  public static let damage: FieldExpr<Int16> = FieldExpr(name: "wear__Weapon__damage", primaryKey: false, hasIndex: false, tableReader: _tr__wear__Weapon__damage, objectReader: _or__wear__Weapon__damage)
  }
  public typealias zzz_AsType__Monster__wear = zzz_wear__Weapon

}

extension MyGame.SampleV2.Orb: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__wear {
  public static let zzz_match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.wear._type == 2)

  public struct zzz_wear__Orb {

  private static func _tr__wear__Orb__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  private static func _or__wear__Orb__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.wear else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "wear__Orb__name", primaryKey: false, hasIndex: true, tableReader: _tr__wear__Orb__name, objectReader: _or__wear__Orb__name)

  private static func _tr__wear__Orb__color(_ table: ByteBuffer) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let tr0 = zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: zzz_DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return (.red, true) }
    return (MyGame.SampleV2.Color(rawValue: tr1.color.rawValue)!, false)
  }
  private static func _or__wear__Orb__color(_ object: Dflat.Atom) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.wear else { return (.red, true) }
    return (or1.color, false)
  }
  public static let color: FieldExpr<MyGame.SampleV2.Color> = FieldExpr(name: "wear__Orb__color", primaryKey: false, hasIndex: false, tableReader: _tr__wear__Orb__color, objectReader: _or__wear__Orb__color)
  }
  public typealias zzz_AsType__Monster__wear = zzz_wear__Orb

}

extension MyGame.SampleV2.Empty: zzz_DflatGen_Proto__MyGame__SampleV2__Monster__wear {
  public static let zzz_match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.wear._type == 3)

  public struct zzz_wear__Empty {
  }
  public typealias zzz_AsType__Monster__wear = zzz_wear__Empty

}
