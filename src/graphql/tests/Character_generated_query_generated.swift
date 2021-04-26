import Dflat
import FlatBuffers

extension Character {

  public struct subtype {

    public static func match<T: zzz_DflatGen_Proto__Character__f6>(_ ofType: T.Type) -> EqualToExpr<
      FieldExpr<Int32, Character>, ValueExpr<Int32, Character>, Character
    > {
      return ofType.zzz_match__Character__f6
    }
    public static func `as`<T: zzz_DflatGen_Proto__Character__f6>(_ ofType: T.Type) -> T
      .zzz_AsType__Character__f6.Type
    {
      return ofType.zzz_AsType__Character__f6.self
    }

    private static func _tr__f6__type(_ table: ByteBuffer) -> Int32? {
      let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
      return Int32(tr0.subtypeType.rawValue)
    }

    private static func _or__f6__type(_ or0: Character) -> Int32? {
      guard let o = or0.subtype else { return nil }
      switch o {
      case .human:
        return 1
      case .droid:
        return 2
      }
    }
    public static let _type: FieldExpr<Int32, Character> = FieldExpr(
      name: "f6__type", primaryKey: false, hasIndex: false, tableReader: _tr__f6__type,
      objectReader: _or__f6__type)

  }

  private static func _tr__f8(_ table: ByteBuffer) -> String? {
    let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
    return tr0.id!
  }
  private static func _or__f8(_ or0: Character) -> String? {
    return or0.id
  }
  public static let id: FieldExpr<String, Character> = FieldExpr(
    name: "__pk0", primaryKey: true, hasIndex: false, tableReader: _tr__f8, objectReader: _or__f8)
}

public protocol zzz_DflatGen_Proto__Character__f6 {
  associatedtype zzz_AsType__Character__f6
  static var zzz_match__Character__f6:
    EqualToExpr<FieldExpr<Int32, Character>, ValueExpr<Int32, Character>, Character>
  { get }
}

extension Character.Human: zzz_DflatGen_Proto__Character__f6 {
  public static let zzz_match__Character__f6:
    EqualToExpr<FieldExpr<Int32, Character>, ValueExpr<Int32, Character>, Character> =
      (Character.subtype._type == 1)

  public struct zzz_f6__Human {

    private static func _tr__f6__u1__f8(_ table: ByteBuffer) -> Double? {
      let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
      guard let tr1 = tr0.subtype(type: zzz_DflatGen_Character_Human.self) else { return nil }
      return tr1.height
    }
    private static func _or__f6__u1__f8(_ or0: Character) -> Double? {
      guard case let .human(or1) = or0.subtype else { return nil }
      return or1.height
    }
    public static let height: FieldExpr<Double, Character> = FieldExpr(
      name: "f6__u1__f8", primaryKey: false, hasIndex: false, tableReader: _tr__f6__u1__f8,
      objectReader: _or__f6__u1__f8)

    private static func _tr__f6__u1__f10(_ table: ByteBuffer) -> String? {
      let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
      guard let tr1 = tr0.subtype(type: zzz_DflatGen_Character_Human.self) else { return nil }
      guard let s = tr1.homePlanet else { return nil }
      return s
    }
    private static func _or__f6__u1__f10(_ or0: Character) -> String? {
      guard case let .human(or1) = or0.subtype else { return nil }
      guard let s = or1.homePlanet else { return nil }
      return s
    }
    public static let homePlanet: FieldExpr<String, Character> = FieldExpr(
      name: "f6__u1__f10", primaryKey: false, hasIndex: false, tableReader: _tr__f6__u1__f10,
      objectReader: _or__f6__u1__f10)

    private static func _tr__f6__u1__f12(_ table: ByteBuffer) -> String? {
      let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
      guard let tr1 = tr0.subtype(type: zzz_DflatGen_Character_Human.self) else { return nil }
      guard let s = tr1.name else { return nil }
      return s
    }
    private static func _or__f6__u1__f12(_ or0: Character) -> String? {
      guard case let .human(or1) = or0.subtype else { return nil }
      guard let s = or1.name else { return nil }
      return s
    }
    public static let name: FieldExpr<String, Character> = FieldExpr(
      name: "f6__u1__f12", primaryKey: false, hasIndex: false, tableReader: _tr__f6__u1__f12,
      objectReader: _or__f6__u1__f12)
  }
  public typealias zzz_AsType__Character__f6 = zzz_f6__Human

}

extension Character.Droid: zzz_DflatGen_Proto__Character__f6 {
  public static let zzz_match__Character__f6:
    EqualToExpr<FieldExpr<Int32, Character>, ValueExpr<Int32, Character>, Character> =
      (Character.subtype._type == 2)

  public struct zzz_f6__Droid {

    private static func _tr__f6__u2__f8(_ table: ByteBuffer) -> String? {
      let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
      guard let tr1 = tr0.subtype(type: zzz_DflatGen_Character_Droid.self) else { return nil }
      guard let s = tr1.name else { return nil }
      return s
    }
    private static func _or__f6__u2__f8(_ or0: Character) -> String? {
      guard case let .droid(or1) = or0.subtype else { return nil }
      guard let s = or1.name else { return nil }
      return s
    }
    public static let name: FieldExpr<String, Character> = FieldExpr(
      name: "f6__u2__f8", primaryKey: false, hasIndex: false, tableReader: _tr__f6__u2__f8,
      objectReader: _or__f6__u2__f8)

    private static func _tr__f6__u2__f10(_ table: ByteBuffer) -> String? {
      let tr0 = zzz_DflatGen_Character.getRootAsCharacter(bb: table)
      guard let tr1 = tr0.subtype(type: zzz_DflatGen_Character_Droid.self) else { return nil }
      guard let s = tr1.primaryFunction else { return nil }
      return s
    }
    private static func _or__f6__u2__f10(_ or0: Character) -> String? {
      guard case let .droid(or1) = or0.subtype else { return nil }
      guard let s = or1.primaryFunction else { return nil }
      return s
    }
    public static let primaryFunction: FieldExpr<String, Character> = FieldExpr(
      name: "f6__u2__f10", primaryKey: false, hasIndex: false, tableReader: _tr__f6__u2__f10,
      objectReader: _or__f6__u2__f10)
  }
  public typealias zzz_AsType__Character__f6 = zzz_f6__Droid

}
