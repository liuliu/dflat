import Dflat
import FlatBuffers
import Foundation
import SQLiteDflat
import SQLite3

extension MyGame.SampleV3 {

public enum Color: Int8, DflatFriendlyValue {
  case red = 0
  case green = 1
  case blue = 2
  public static func < (lhs: Color, rhs: Color) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

public enum Equipment: Equatable {
  case weapon(_: Weapon)
  case orb(_: Orb)
  case empty(_: Empty)
}

public struct Vec3: Equatable, FlatBuffersDecodable {
  public var x: Float32
  public var y: Float32
  public var z: Float32
  public init(x: Float32? = 0.0, y: Float32? = 0.0, z: Float32? = 0.0) {
    self.x = x ?? 0.0
    self.y = y ?? 0.0
    self.z = z ?? 0.0
  }
  public init(_ obj: zzz_DflatGen_MyGame_SampleV3_Vec3) {
    self.x = obj.x
    self.y = obj.y
    self.z = obj.z
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    // Assuming this is the root
    Self(bb.read(def: zzz_DflatGen_MyGame_SampleV3_Vec3.self, position: Int(bb.read(def: UOffset.self, position: bb.reader)) + bb.reader))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_MyGame_SampleV3_Vec3>.verify(&verifier, at: 0, of: zzz_DflatGen_MyGame_SampleV3_Vec3.self)
      return true
    } catch {
      return false
    }
  }
}

public struct Empty: Equatable, FlatBuffersDecodable {
  public init() {
  }
  public init(_ obj: zzz_DflatGen_MyGame_SampleV3_Empty) {
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_MyGame_SampleV3_Empty.getRootAsEmpty(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_MyGame_SampleV3_Empty>.verify(&verifier, at: 0, of: zzz_DflatGen_MyGame_SampleV3_Empty.self)
      return true
    } catch {
      return false
    }
  }
}

public struct Monster: Equatable, FlatBuffersDecodable {
  public var pos: MyGame.SampleV3.Vec3?
  public var mana: Int16
  public var hp: Int16
  public var name: String?
  public var color: MyGame.SampleV3.Color
  public var inventory: [UInt8]
  public var weapons: [MyGame.SampleV3.Weapon]
  public var equipped: MyGame.SampleV3.Equipment?
  public var colors: [MyGame.SampleV3.Color]
  public var path: [MyGame.SampleV3.Vec3]
  public var wear: MyGame.SampleV3.Equipment?
  public init(pos: MyGame.SampleV3.Vec3? = nil, mana: Int16? = 150, hp: Int16? = 100, name: String? = nil, color: MyGame.SampleV3.Color? = .blue, inventory: [UInt8]? = [], weapons: [MyGame.SampleV3.Weapon]? = [], equipped: MyGame.SampleV3.Equipment? = nil, colors: [MyGame.SampleV3.Color]? = [], path: [MyGame.SampleV3.Vec3]? = [], wear: MyGame.SampleV3.Equipment? = nil) {
    self.pos = pos ?? nil
    self.mana = mana ?? 150
    self.hp = hp ?? 100
    self.name = name ?? nil
    self.color = color ?? .blue
    self.inventory = inventory ?? []
    self.weapons = weapons ?? []
    self.equipped = equipped ?? nil
    self.colors = colors ?? []
    self.path = path ?? []
    self.wear = wear ?? nil
  }
  public init(_ obj: zzz_DflatGen_MyGame_SampleV3_Monster) {
    self.pos = obj.pos.map { MyGame.SampleV3.Vec3($0) }
    self.mana = obj.mana
    self.hp = obj.hp
    self.name = obj.name
    self.color = MyGame.SampleV3.Color(rawValue: obj.color.rawValue) ?? .blue
    self.inventory = obj.inventory
    var __weapons = [MyGame.SampleV3.Weapon]()
    for i: Int32 in 0..<obj.weaponsCount {
      guard let o = obj.weapons(at: i) else { break }
      __weapons.append(MyGame.SampleV3.Weapon(o))
    }
    self.weapons = __weapons
    switch obj.equippedType {
    case .none_:
      self.equipped = nil
    case .weapon:
      self.equipped = obj.equipped(type: zzz_DflatGen_MyGame_SampleV3_Weapon.self).map { .weapon(Weapon($0)) }
    case .orb:
      self.equipped = obj.equipped(type: zzz_DflatGen_MyGame_SampleV3_Orb.self).map { .orb(Orb($0)) }
    case .empty:
      self.equipped = obj.equipped(type: zzz_DflatGen_MyGame_SampleV3_Empty.self).map { .empty(Empty($0)) }
    }
    var __colors = [MyGame.SampleV3.Color]()
    for i: Int32 in 0..<obj.colorsCount {
      guard let o = obj.colors(at: i) else { break }
      __colors.append(MyGame.SampleV3.Color(rawValue: o.rawValue) ?? .red)
    }
    self.colors = __colors
    var __path = [MyGame.SampleV3.Vec3]()
    for i: Int32 in 0..<obj.pathCount {
      guard let o = obj.path(at: i) else { break }
      __path.append(MyGame.SampleV3.Vec3(o))
    }
    self.path = __path
    switch obj.wearType {
    case .none_:
      self.wear = nil
    case .weapon:
      self.wear = obj.wear(type: zzz_DflatGen_MyGame_SampleV3_Weapon.self).map { .weapon(Weapon($0)) }
    case .orb:
      self.wear = obj.wear(type: zzz_DflatGen_MyGame_SampleV3_Orb.self).map { .orb(Orb($0)) }
    case .empty:
      self.wear = obj.wear(type: zzz_DflatGen_MyGame_SampleV3_Empty.self).map { .empty(Empty($0)) }
    }
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_MyGame_SampleV3_Monster.getRootAsMonster(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_MyGame_SampleV3_Monster>.verify(&verifier, at: 0, of: zzz_DflatGen_MyGame_SampleV3_Monster.self)
      return true
    } catch {
      return false
    }
  }
}

public struct Weapon: Equatable, FlatBuffersDecodable {
  public var name: String?
  public var damage: Int16
  public init(name: String? = nil, damage: Int16? = 0) {
    self.name = name ?? nil
    self.damage = damage ?? 0
  }
  public init(_ obj: zzz_DflatGen_MyGame_SampleV3_Weapon) {
    self.name = obj.name
    self.damage = obj.damage
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_MyGame_SampleV3_Weapon.getRootAsWeapon(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_MyGame_SampleV3_Weapon>.verify(&verifier, at: 0, of: zzz_DflatGen_MyGame_SampleV3_Weapon.self)
      return true
    } catch {
      return false
    }
  }
}

public struct Orb: Equatable, FlatBuffersDecodable {
  public var name: String?
  public var color: MyGame.SampleV3.Color
  public init(name: String? = nil, color: MyGame.SampleV3.Color? = .red) {
    self.name = name ?? nil
    self.color = color ?? .red
  }
  public init(_ obj: zzz_DflatGen_MyGame_SampleV3_Orb) {
    self.name = obj.name
    self.color = MyGame.SampleV3.Color(rawValue: obj.color.rawValue) ?? .red
  }
  public static func from(byteBuffer bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_MyGame_SampleV3_Orb.getRootAsOrb(bb: bb))
  }
  public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
    do {
      var bb = bb
      var verifier = try Verifier(buffer: &bb)
      try ForwardOffset<zzz_DflatGen_MyGame_SampleV3_Orb>.verify(&verifier, at: 0, of: zzz_DflatGen_MyGame_SampleV3_Orb.self)
      return true
    } catch {
      return false
    }
  }
}

}

// MARK: - MyGame.SampleV3
