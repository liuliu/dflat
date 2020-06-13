import Dflat
import FlatBuffers

public extension MyGame.Sample.Monster {

  static private func _tr_mana(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (tr.mana, false)
  }

  static private func _or_mana(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or = object as! MyGame.Sample.Monster
    return (or.mana, false)
  }

  static let mana: FieldExpr<Int16> = FieldExpr(name: "mana", primaryKey: false, hasIndex: false, tableReader: _tr_mana, objectReader: _or_mana)

  static private func _tr_hp(_ table: ByteBuffer) -> (result: Int16, unknown: Bool) {
    let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (tr.hp, false)
  }

  static private func _or_hp(_ object: Dflat.Atom) -> (result: Int16, unknown: Bool) {
    let or = object as! MyGame.Sample.Monster
    return (or.hp, false)
  }

  static let hp: FieldExpr<Int16> = FieldExpr(name: "hp", primaryKey: false, hasIndex: false, tableReader: _tr_hp, objectReader: _or_hp)

  static private func _tr_name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
    let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (tr.name!, false)
  }

  static private func _or_name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
    let or = object as! MyGame.Sample.Monster
    return (or.name, false)
  }

  static let name: FieldExpr<String> = FieldExpr(name: "__pk", primaryKey: true, hasIndex: false, tableReader: _tr_name, objectReader: _or_name)

  static private func _tr_color(_ table: ByteBuffer) -> (result: MyGame.Sample.Color, unknown: Bool) {
    let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    return (MyGame.Sample.Color(rawValue: tr.color.rawValue)!, false)
  }

  static private func _or_color(_ object: Dflat.Atom) -> (result: MyGame.Sample.Color, unknown: Bool) {
    let or = object as! MyGame.Sample.Monster
    return (or.color, false)
  }

  static let color: FieldExpr<MyGame.Sample.Color> = FieldExpr(name: "color", primaryKey: false, hasIndex: false, tableReader: _tr_color, objectReader: _or_color)

  struct pos {

    static private func _tr_pos__x(_ table: ByteBuffer) -> (result: Float, unknown: Bool) {
      let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
      guard let pos = tr.pos else { return (Float(), true) }
      return (pos.x, false)
    }

    static private func _or_pos__x(_ object: Dflat.Atom) -> (result: Float, unknown: Bool) {
      let or = object as! MyGame.Sample.Monster
      guard let pos = or.pos else { return (Float(), true) }
      return (pos.x, false)
    }

    public static let x: FieldExpr<Float> = FieldExpr(name: "pos__x", primaryKey: false, hasIndex: false, tableReader: _tr_pos__x, objectReader: _or_pos__x)

    static private func _tr_pos__y(_ table: ByteBuffer) -> (result: Float, unknown: Bool) {
      let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
      guard let pos = tr.pos else { return (Float(), true) }
      return (pos.y, false)
    }

    static private func _or_pos__y(_ object: Dflat.Atom) -> (result: Float, unknown: Bool) {
      let or = object as! MyGame.Sample.Monster
      guard let pos = or.pos else { return (Float(), true) }
      return (pos.y, false)
    }

    public static let y: FieldExpr<Float> = FieldExpr(name: "pos__y", primaryKey: false, hasIndex: false, tableReader: _tr_pos__y, objectReader: _or_pos__y)

    static private func _tr_pos__z(_ table: ByteBuffer) -> (result: Float, unknown: Bool) {
      let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
      guard let pos = tr.pos else { return (Float(), true) }
      return (pos.z, false)
    }

    static private func _or_pos__z(_ object: Dflat.Atom) -> (result: Float, unknown: Bool) {
      let or = object as! MyGame.Sample.Monster
      guard let pos = or.pos else { return (Float(), true) }
      return (pos.z, false)
    }

    public static let z: FieldExpr<Float> = FieldExpr(name: "pos__z", primaryKey: false, hasIndex: false, tableReader: _tr_pos__z, objectReader: _or_pos__z)

  }

  struct equipped {
    public static func match<T: MyGame__Sample__Monster__equipped>(_ ofType: T.Type) -> FieldExpr<Bool> {
      return ofType.match__Monster__equipped
    }
    public static func `as`<T: MyGame__Sample__Monster__equipped>(_ ofType: T.Type) -> T.AsType.Type {
      return T.AsType.self
    }
  }
}

public protocol MyGame__Sample__Monster__equipped {
  associatedtype AsType
  static var match__Monster__equipped: FieldExpr<Bool> { get }
}

extension MyGame.Sample.Weapon: MyGame__Sample__Monster__equipped {
  static private func _tr_equipped__match__weapon(_ table: ByteBuffer) -> (result: Bool, unknown: Bool) {
    let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
    switch tr.equippedType {
    case .none_:
      return (false, true)
    case .weapon:
      return (true, false)
    }
  }
  static private func _or_equipped__match__weapon(_ object: Dflat.Atom) -> (result: Bool, unknown: Bool) {
    let or = object as! MyGame.Sample.Monster
    guard let equipped = or.equipped else { return (false, true) }
    switch equipped {
      case .weapon:
        return (true, true)
    }
  }
  public static let match__Monster__equipped: FieldExpr<Bool> = FieldExpr(name: "equipped__type", primaryKey: false, hasIndex: false, tableReader: _tr_equipped__match__weapon, objectReader: _or_equipped__match__weapon)

  public struct _equipped__Weapon {

    static private func _tr_equipped__Weapon_name(_ table: ByteBuffer) -> (result: String, unknown: Bool) {
      let tr = FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: table)
      guard let name = tr.equipped(type: FlatBuffers_Generated.MyGame.Sample.Weapon.self)?.name else { return (String(), true) }
      return (name, false)
    }

    static private func _or_equipped__Weapon_name(_ object: Dflat.Atom) -> (result: String, unknown: Bool) {
      let or = object as! MyGame.Sample.Monster
      guard let equipped = or.equipped else { return (String(), true) }
      switch equipped {
        case .weapon(let weapon):
          guard let name = weapon.name else { return (String(), true) }
          return (name, false)
      }
    }

    public static let name: FieldExpr<String> = FieldExpr(name: "equipped__Weapon_name", primaryKey: false, hasIndex: false, tableReader: _tr_equipped__Weapon_name, objectReader: _or_equipped__Weapon_name)
  }
  public typealias AsType = _equipped__Weapon
}

