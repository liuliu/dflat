import Dflat
import FlatBuffers
import SQLite3
import SQLiteDflat

// MARK - SQLiteValue for Enumerations

extension MyGame.Sample.Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension MyGame.Sample.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let start = zzz_DflatGen_MyGame_Sample_Weapon.startWeapon(&flatBufferBuilder)
    zzz_DflatGen_MyGame_Sample_Weapon.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_Sample_Weapon.add(damage: self.damage, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_Sample_Weapon.endWeapon(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.Sample.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.Sample.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    let __color = zzz_DflatGen_MyGame_Sample_Color(rawValue: self.color.rawValue) ?? .red
    let start = zzz_DflatGen_MyGame_Sample_Orb.startOrb(&flatBufferBuilder)
    zzz_DflatGen_MyGame_Sample_Orb.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_Sample_Orb.add(color: __color, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_Sample_Orb.endOrb(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.Sample.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

// MARK - ChangeRequest
