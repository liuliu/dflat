import Dflat
import FlatBuffers

public extension MyGame.Sample.Monster {

  struct pos {

  private static func _tr__f4__f0(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return nil }
    return tr1.x
  }
  private static func _or__f4__f0(_ or0: MyGame.Sample.Monster) -> Float32? {
    guard let or1 = or0.pos else { return nil }
    return or1.x
  }
  public static let x: FieldExpr<Float32, MyGame.Sample.Monster> = FieldExpr(name: "f4__f0", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f0, objectReader: _or__f4__f0)

  private static func _tr__f4__f4(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return nil }
    return tr1.y
  }
  private static func _or__f4__f4(_ or0: MyGame.Sample.Monster) -> Float32? {
    guard let or1 = or0.pos else { return nil }
    return or1.y
  }
  public static let y: FieldExpr<Float32, MyGame.Sample.Monster> = FieldExpr(name: "f4__f4", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f4, objectReader: _or__f4__f4)

  private static func _tr__f4__f8(_ table: ByteBuffer) -> Float32? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.pos else { return nil }
    return tr1.z
  }
  private static func _or__f4__f8(_ or0: MyGame.Sample.Monster) -> Float32? {
    guard let or1 = or0.pos else { return nil }
    return or1.z
  }
  public static let z: FieldExpr<Float32, MyGame.Sample.Monster> = FieldExpr(name: "f4__f8", primaryKey: false, hasIndex: false, tableReader: _tr__f4__f8, objectReader: _or__f4__f8)

  }

  private static func _tr__f6(_ table: ByteBuffer) -> Int16? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    return tr0.mana
  }
  private static func _or__f6(_ or0: MyGame.Sample.Monster) -> Int16? {
    return or0.mana
  }
  static let mana: FieldExpr<Int16, MyGame.Sample.Monster> = FieldExpr(name: "f6", primaryKey: false, hasIndex: true, tableReader: _tr__f6, objectReader: _or__f6)

  private static func _tr__f8(_ table: ByteBuffer) -> Int16? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    return tr0.hp
  }
  private static func _or__f8(_ or0: MyGame.Sample.Monster) -> Int16? {
    return or0.hp
  }
  static let hp: FieldExpr<Int16, MyGame.Sample.Monster> = FieldExpr(name: "f8", primaryKey: false, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)

  private static func _tr__f10(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    return tr0.name!
  }
  private static func _or__f10(_ or0: MyGame.Sample.Monster) -> String? {
    return or0.name
  }
  static let name: FieldExpr<String, MyGame.Sample.Monster> = FieldExpr(name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f10, objectReader: _or__f10)

  private static func _tr__f12(_ table: ByteBuffer) -> MyGame.Sample.Color? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    return MyGame.Sample.Color(rawValue: tr0.color.rawValue)!
  }
  private static func _or__f12(_ or0: MyGame.Sample.Monster) -> MyGame.Sample.Color? {
    return or0.color
  }
  static let color: FieldExpr<MyGame.Sample.Color, MyGame.Sample.Monster> = FieldExpr(name: "__pk1", primaryKey: true, hasIndex: false, tableReader: _tr__f12, objectReader: _or__f12)

  struct equipped {

  public static func match<T: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26>(_ ofType: T.Type) -> EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32, MyGame.Sample.Monster>, MyGame.Sample.Monster> {
    return ofType.zzz_match__Monster__f26
  }
  public static func `as`<T: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26>(_ ofType: T.Type) -> T.zzz_AsType__Monster__f26.Type {
    return ofType.zzz_AsType__Monster__f26.self
  }

  private static func _tr__f26__type(_ table: ByteBuffer) -> Int32? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    return Int32(tr0.equippedType.rawValue)
  }

  private static func _or__f26__type(_ or0: MyGame.Sample.Monster) -> Int32? {
    guard let o = or0.equipped else { return nil }
    switch o {
    case .weapon:
      return 1
    case .orb:
      return 2
    }
  }
  public static let _type: FieldExpr<Int32, MyGame.Sample.Monster> = FieldExpr(name: "f26__type", primaryKey: false, hasIndex: true, tableReader: _tr__f26__type, objectReader: _or__f26__type)

  }
}

public protocol zzz_DflatGen_Proto__MyGame__Sample__Monster__f26 {
  associatedtype zzz_AsType__Monster__f26
  static var zzz_match__Monster__f26: EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32, MyGame.Sample.Monster>, MyGame.Sample.Monster> { get }
}

extension MyGame.Sample.Weapon: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26 {
  public static let zzz_match__Monster__f26: EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32, MyGame.Sample.Monster>, MyGame.Sample.Monster> = (MyGame.Sample.Monster.equipped._type == 1)

  public struct zzz_f26__Weapon {

  private static func _tr__f26__u1__f4(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen_MyGame_Sample_Weapon.self) else { return nil }
    guard let s = tr1.name else { return nil }
    return s
  }
  private static func _or__f26__u1__f4(_ or0: MyGame.Sample.Monster) -> String? {
    guard case let .weapon(or1) = or0.equipped else { return nil }
    guard let s = or1.name else { return nil }
    return s
  }
  public static let name: FieldExpr<String, MyGame.Sample.Monster> = FieldExpr(name: "f26__u1__f4", primaryKey: false, hasIndex: false, tableReader: _tr__f26__u1__f4, objectReader: _or__f26__u1__f4)

  private static func _tr__f26__u1__f6(_ table: ByteBuffer) -> Int16? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen_MyGame_Sample_Weapon.self) else { return nil }
    return tr1.damage
  }
  private static func _or__f26__u1__f6(_ or0: MyGame.Sample.Monster) -> Int16? {
    guard case let .weapon(or1) = or0.equipped else { return nil }
    return or1.damage
  }
  public static let damage: FieldExpr<Int16, MyGame.Sample.Monster> = FieldExpr(name: "f26__u1__f6", primaryKey: false, hasIndex: false, tableReader: _tr__f26__u1__f6, objectReader: _or__f26__u1__f6)
  }
  public typealias zzz_AsType__Monster__f26 = zzz_f26__Weapon

}

extension MyGame.Sample.Orb: zzz_DflatGen_Proto__MyGame__Sample__Monster__f26 {
  public static let zzz_match__Monster__f26: EqualToExpr<FieldExpr<Int32, MyGame.Sample.Monster>, ValueExpr<Int32, MyGame.Sample.Monster>, MyGame.Sample.Monster> = (MyGame.Sample.Monster.equipped._type == 2)

  public struct zzz_f26__Orb {

  private static func _tr__f26__u2__f4(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen_MyGame_Sample_Orb.self) else { return nil }
    guard let s = tr1.name else { return nil }
    return s
  }
  private static func _or__f26__u2__f4(_ or0: MyGame.Sample.Monster) -> String? {
    guard case let .orb(or1) = or0.equipped else { return nil }
    guard let s = or1.name else { return nil }
    return s
  }
  public static let name: FieldExpr<String, MyGame.Sample.Monster> = FieldExpr(name: "f26__u2__f4", primaryKey: false, hasIndex: true, tableReader: _tr__f26__u2__f4, objectReader: _or__f26__u2__f4)

  private static func _tr__f26__u2__f6(_ table: ByteBuffer) -> MyGame.Sample.Color? {
    let tr0 = zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: table)
    guard let tr1 = tr0.equipped(type: zzz_DflatGen_MyGame_Sample_Orb.self) else { return nil }
    return MyGame.Sample.Color(rawValue: tr1.color.rawValue)!
  }
  private static func _or__f26__u2__f6(_ or0: MyGame.Sample.Monster) -> MyGame.Sample.Color? {
    guard case let .orb(or1) = or0.equipped else { return nil }
    return or1.color
  }
  public static let color: FieldExpr<MyGame.Sample.Color, MyGame.Sample.Monster> = FieldExpr(name: "f26__u2__f6", primaryKey: false, hasIndex: false, tableReader: _tr__f26__u2__f6, objectReader: _or__f26__u2__f6)
  }
  public typealias zzz_AsType__Monster__f26 = zzz_f26__Orb

}
