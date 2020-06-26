import Dflat
import FlatBuffers

extension MyGame.SampleV2.Monster {

  struct pos {

  static private func _tr__pos__x(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.x, false)
  }
  static private func _or__pos__x(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.x, false)
  }
  public static let x: FieldExpr<Float32> = FieldExpr(name: "pos__x", primaryKey: false, hasIndex: false, tableReader: _tr__pos__x, objectReader: _or__pos__x)

  static private func _tr__pos__y(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.y, false)
  }
  static private func _or__pos__y(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.y, false)
  }
  public static let y: FieldExpr<Float32> = FieldExpr(name: "pos__y", primaryKey: false, hasIndex: false, tableReader: _tr__pos__y, objectReader: _or__pos__y)

  static private func _tr__pos__z(_ table: ByteBuffer) -> (result: Float32, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return (0.0, true) }
    return (tr1.z, false)
  }
  static private func _or__pos__z(_ object: Dflat.Atom) -> (result: Float32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let or1 = or0.pos else { return (0.0, true) }
    return (or1.z, false)
  }
  public static let z: FieldExpr<Float32> = FieldExpr(name: "pos__z", primaryKey: false, hasIndex: false, tableReader: _tr__pos__z, objectReader: _or__pos__z)

  }

  static private func _tr__mana(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (tr0.mana, false)
  }
  static private func _or__mana(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.mana, false)
  }
  static let mana: FieldExpr<Int16> = FieldExpr(name: "mana", primaryKey: false, hasIndex: true, tableReader: _tr__mana, objectReader: _or__mana)

  static private func _tr__hp(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (tr0.hp, false)
  }
  static private func _or__hp(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.hp, false)
  }
  static let hp: FieldExpr<Int16> = FieldExpr(name: "hp", primaryKey: false, hasIndex: true, tableReader: _tr__hp, objectReader: _or__hp)

  static private func _tr__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (tr0.name!, false)
  }
  static private func _or__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.name, false)
  }
  static let name: FieldExpr<String> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__name, objectReader: _or__name)

  static private func _tr__color(_ table: ByteBuffer) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (MyGame.SampleV2.Color(rawValue: tr0.color.rawValue)!, false)
  }
  static private func _or__color(_ object: Dflat.Atom) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    return (or0.color, false)
  }
  static let color: FieldExpr<MyGame.SampleV2.Color> = FieldExpr(name: "__pk1", primaryKey: true, hasIndex: false, tableReader: _tr__color, objectReader: _or__color)

  struct equipped {

  public static func match<T: MyGame__SampleV2__Monster__equipped>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> {
    return ofType.match__Monster__equipped
  }
  public static func `as`<T: MyGame__SampleV2__Monster__equipped>(_ ofType: T.Type) -> T.AsType__Monster__equipped.Type {
    return ofType.AsType__Monster__equipped.self
  }

  static private func _tr__equipped__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (Int32(tr0.equippedType.rawValue), false)
  }

  static private func _or__equipped__type(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let o = or0.equipped else { return (-1, true) }
    switch o {
    case .weapon:
      return (1, false)
    case .orb:
      return (2, false)
    }
  }
  public static let _type: FieldExpr<Int32> = FieldExpr(name: "equipped__type", primaryKey: false, hasIndex: true, tableReader: _tr__equipped__type, objectReader: _or__equipped__type)

  }

  struct wear {

  public static func match<T: MyGame__SampleV2__Monster__wear>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> {
    return ofType.match__Monster__wear
  }
  public static func `as`<T: MyGame__SampleV2__Monster__wear>(_ ofType: T.Type) -> T.AsType__Monster__wear.Type {
    return ofType.AsType__Monster__wear.self
  }

  static private func _tr__wear__type(_ table: ByteBuffer) -> (result: Int32, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    return (Int32(tr0.wearType.rawValue), false)
  }

  static private func _or__wear__type(_ object: Dflat.Atom) -> (result: Int32, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard let o = or0.wear else { return (-1, true) }
    switch o {
    case .weapon:
      return (1, false)
    case .orb:
      return (2, false)
    }
  }
  public static let _type: FieldExpr<Int32> = FieldExpr(name: "wear__type", primaryKey: false, hasIndex: false, tableReader: _tr__wear__type, objectReader: _or__wear__type)

  }
}

public protocol MyGame__SampleV2__Monster__equipped {
  associatedtype AsType__Monster__equipped
  static var match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> { get }
}

extension MyGame.SampleV2.Weapon: MyGame__SampleV2__Monster__equipped {
  public static let match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.equipped._type == 1)

  public struct _equipped__Weapon {

  static private func _tr__equipped__Weapon__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  static private func _or__equipped__Weapon__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.equipped else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "equipped__Weapon__name", primaryKey: false, hasIndex: false, tableReader: _tr__equipped__Weapon__name, objectReader: _or__equipped__Weapon__name)

  static private func _tr__equipped__Weapon__damage(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return (0, true) }
    return (tr1.damage, false)
  }
  static private func _or__equipped__Weapon__damage(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.equipped else { return (0, true) }
    return (or1.damage, false)
  }
  public static let damage: FieldExpr<Int16> = FieldExpr(name: "equipped__Weapon__damage", primaryKey: false, hasIndex: false, tableReader: _tr__equipped__Weapon__damage, objectReader: _or__equipped__Weapon__damage)
  }
  public typealias AsType__Monster__equipped = _equipped__Weapon

}

extension MyGame.SampleV2.Orb: MyGame__SampleV2__Monster__equipped {
  public static let match__Monster__equipped: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.equipped._type == 2)

  public struct _equipped__Orb {

  static private func _tr__equipped__Orb__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  static private func _or__equipped__Orb__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.equipped else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "equipped__Orb__name", primaryKey: false, hasIndex: true, tableReader: _tr__equipped__Orb__name, objectReader: _or__equipped__Orb__name)

  static private func _tr__equipped__Orb__color(_ table: ByteBuffer) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return (.red, true) }
    return (MyGame.SampleV2.Color(rawValue: tr1.color.rawValue)!, false)
  }
  static private func _or__equipped__Orb__color(_ object: Dflat.Atom) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.equipped else { return (.red, true) }
    return (or1.color, false)
  }
  public static let color: FieldExpr<MyGame.SampleV2.Color> = FieldExpr(name: "equipped__Orb__color", primaryKey: false, hasIndex: false, tableReader: _tr__equipped__Orb__color, objectReader: _or__equipped__Orb__color)
  }
  public typealias AsType__Monster__equipped = _equipped__Orb

}

public protocol MyGame__SampleV2__Monster__wear {
  associatedtype AsType__Monster__wear
  static var match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> { get }
}

extension MyGame.SampleV2.Weapon: MyGame__SampleV2__Monster__wear {
  public static let match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.wear._type == 1)

  public struct _wear__Weapon {

  static private func _tr__wear__Weapon__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  static private func _or__wear__Weapon__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.wear else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "wear__Weapon__name", primaryKey: false, hasIndex: false, tableReader: _tr__wear__Weapon__name, objectReader: _or__wear__Weapon__name)

  static private func _tr__wear__Weapon__damage(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Weapon.self) else { return (0, true) }
    return (tr1.damage, false)
  }
  static private func _or__wear__Weapon__damage(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .weapon(or1) = or0.wear else { return (0, true) }
    return (or1.damage, false)
  }
  public static let damage: FieldExpr<Int16> = FieldExpr(name: "wear__Weapon__damage", primaryKey: false, hasIndex: false, tableReader: _tr__wear__Weapon__damage, objectReader: _or__wear__Weapon__damage)
  }
  public typealias AsType__Monster__wear = _wear__Weapon

}

extension MyGame.SampleV2.Orb: MyGame__SampleV2__Monster__wear {
  public static let match__Monster__wear: EqualToExpr<FieldExpr<Int32>, ValueExpr<Int32>> = (MyGame.SampleV2.Monster.wear._type == 2)

  public struct _wear__Orb {

  static private func _tr__wear__Orb__name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return ("", true) }
    guard let s = tr1.name else { return ("", true) }
    return (s, false)
  }
  static private func _or__wear__Orb__name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.wear else { return ("", true) }
    guard let s = or1.name else { return ("", true) }
    return (s, false)
  }
  public static let name: FieldExpr<String> = FieldExpr(name: "wear__Orb__name", primaryKey: false, hasIndex: true, tableReader: _tr__wear__Orb__name, objectReader: _or__wear__Orb__name)

  static private func _tr__wear__Orb__color(_ table: ByteBuffer) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let tr0 = DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.wear(type: DflatGen__MyGame__SampleV2__Monster.MyGame.SampleV2.Orb.self) else { return (.red, true) }
    return (MyGame.SampleV2.Color(rawValue: tr1.color.rawValue)!, false)
  }
  static private func _or__wear__Orb__color(_ object: Dflat.Atom) -> (result: MyGame.SampleV2.Color, unknown: Bool) {
    let or0 = object as! MyGame.SampleV2.Monster
    guard case let .orb(or1) = or0.wear else { return (.red, true) }
    return (or1.color, false)
  }
  public static let color: FieldExpr<MyGame.SampleV2.Color> = FieldExpr(name: "wear__Orb__color", primaryKey: false, hasIndex: false, tableReader: _tr__wear__Orb__color, objectReader: _or__wear__Orb__color)
  }
  public typealias AsType__Monster__wear = _wear__Orb

}
