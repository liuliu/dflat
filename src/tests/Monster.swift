import Dflat
import FlatBuffers

public enum MyGame {
public enum Sample {

public enum Color: Int8, DflatFriendlyValue {
  case red = 0
  case green = 1
  case blue = 2
  public static func < (lhs: Color, rhs: Color) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public enum Equipment {
  case weapon(_: Weapon)
}

public struct Vec3 {
  var x: Float
  var y: Float
  var z: Float
  public init(_ vec3: FlatBuffers_Generated.MyGame.Sample.Vec3) {
    self.x = vec3.x
    self.y = vec3.y
    self.z = vec3.z
  }
}

public final class Monster: Dflat.Atom {
  let pos: Vec3?
  let mana: Int16
  let hp: Int16
  let name: String // This is the primary key.
  let inventory: [UInt8]
  let color: Color
  let weapons: [Weapon]
  let equipped: Equipment?
  let path: [Vec3]
  public init(pos: Vec3?, name: String, inventory: [UInt8], weapons: [Weapon], equipped: Equipment?, path: [Vec3], mana: Int16 = 150, hp: Int16 = 100, color: Color = .blue) {
    self.pos = pos
    self.mana = mana
    self.hp = hp
    self.name = name
    self.inventory = inventory
    self.color = color
    self.weapons = weapons
    self.equipped = equipped
    self.path = path
    super.init()
  }

  public init(_ monster: FlatBuffers_Generated.MyGame.Sample.Monster) {
    self.pos = monster.pos.map { Vec3($0) }
    self.mana = monster.mana
    self.hp = monster.hp
    self.name = monster.name!
    self.inventory = monster.inventory
    var weapons = [Weapon]()
    for i: Int32 in 0..<monster.weaponsCount {
      guard let o = monster.weapons(at: i) else { break }
      weapons.append(Weapon(o))
    }
    self.color = Color(rawValue: monster.color.rawValue) ?? .blue
    self.weapons = weapons
    switch monster.equippedType {
      case .none_:
        self.equipped = nil
      case .weapon:
        self.equipped = monster.equipped(type: FlatBuffers_Generated.MyGame.Sample.Weapon.self).map { .weapon(Weapon($0)) }
    }
    var path = [Vec3]()
    for i: Int32 in 0..<monster.pathCount {
      guard let o = monster.path(at: i) else { break }
      path.append(Vec3(o))
    }
    self.path = path
    super.init()
  }
  
  override public convenience init(bb: ByteBuffer) {
    self.init(FlatBuffers_Generated.MyGame.Sample.Monster.getRootAsMonster(bb: bb))
  }
}

public struct Weapon {
  var name: String?
  var damage: Int16
  public init(_ weapon: FlatBuffers_Generated.MyGame.Sample.Weapon) {
    self.name = weapon.name
    self.damage = weapon.damage
  }
}

}

// MARK: - Sample

}

// MARK: - MyGame
