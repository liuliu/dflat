import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

// MARK - SQLiteValue for Enumerations

extension MyGame.SampleV3.Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension MyGame.SampleV3.Equipment: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    case .weapon(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .orb(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .empty(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: zzz_DflatGen_MyGame_SampleV3_Equipment {
    switch self {
    case .weapon(_):
      return zzz_DflatGen_MyGame_SampleV3_Equipment.weapon
    case .orb(_):
      return zzz_DflatGen_MyGame_SampleV3_Equipment.orb
    case .empty(_):
      return zzz_DflatGen_MyGame_SampleV3_Equipment.empty
    }
  }
}

extension Optional where Wrapped == MyGame.SampleV3.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: zzz_DflatGen_MyGame_SampleV3_Equipment {
    self.map { $0._type } ?? .none_
  }
}

extension MyGame.SampleV3.Vec3: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    flatBufferBuilder.create(struct: zzz_DflatGen_MyGame_SampleV3_Vec3(self))
  }
}

extension zzz_DflatGen_MyGame_SampleV3_Vec3 {
  init(_ obj: MyGame.SampleV3.Vec3) {
    self.init(x: obj.x, y: obj.y, z: obj.z)
  }
  init?(_ obj: MyGame.SampleV3.Vec3?) {
    guard let obj = obj else { return nil }
    self.init(obj)
  }
}

extension MyGame.SampleV3.Empty: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let start = zzz_DflatGen_MyGame_SampleV3_Empty.startEmpty(&flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV3_Empty.endEmpty(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV3.Empty {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV3.Monster: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = flatBufferBuilder.create(string: self.name)
    let __color = zzz_DflatGen_MyGame_SampleV3_Color(rawValue: self.color.rawValue) ?? .blue
    let __vector_inventory = flatBufferBuilder.createVector(self.inventory)
    var __weapons = [Offset<UOffset>]()
    for i in self.weapons {
      __weapons.append(i.to(flatBufferBuilder: &flatBufferBuilder))
    }
    let __vector_weapons = flatBufferBuilder.createVector(ofOffsets: __weapons)
    let __equippedType = self.equipped._type
    let __equipped = self.equipped.to(flatBufferBuilder: &flatBufferBuilder)
    var __colors = [zzz_DflatGen_MyGame_SampleV3_Color]()
    for i in self.colors {
      __colors.append(zzz_DflatGen_MyGame_SampleV3_Color(rawValue: i.rawValue) ?? .red)
    }
    let __vector_colors = flatBufferBuilder.createVector(__colors)
    zzz_DflatGen_MyGame_SampleV3_Monster.startVectorOfPath(self.path.count, in: &flatBufferBuilder)
    for i in self.path {
      _ = flatBufferBuilder.create(struct: zzz_DflatGen_MyGame_SampleV3_Vec3(i))
    }
    let __vector_path = flatBufferBuilder.endVector(len: self.path.count)
    let __wearType = self.wear._type
    let __wear = self.wear.to(flatBufferBuilder: &flatBufferBuilder)
    let start = zzz_DflatGen_MyGame_SampleV3_Monster.startMonster(&flatBufferBuilder)
    let __pos = zzz_DflatGen_MyGame_SampleV3_Vec3(self.pos)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(pos: __pos, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(mana: self.mana, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(hp: self.hp, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(color: __color, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.addVectorOf(
      inventory: __vector_inventory, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.addVectorOf(weapons: __vector_weapons, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(equippedType: __equippedType, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(equipped: __equipped, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.addVectorOf(colors: __vector_colors, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.addVectorOf(path: __vector_path, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(wearType: __wearType, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Monster.add(wear: __wear, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV3_Monster.endMonster(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV3.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV3.Weapon: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_MyGame_SampleV3_Weapon.startWeapon(&flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Weapon.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Weapon.add(damage: self.damage, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV3_Weapon.endWeapon(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV3.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV3.Orb: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __color = zzz_DflatGen_MyGame_SampleV3_Color(rawValue: self.color.rawValue) ?? .red
    let start = zzz_DflatGen_MyGame_SampleV3_Orb.startOrb(&flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Orb.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV3_Orb.add(color: __color, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV3_Orb.endOrb(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV3.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

// MARK - ChangeRequest
