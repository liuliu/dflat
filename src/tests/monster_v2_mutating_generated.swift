import Dflat
import SQLiteDflat
import SQLite3
import FlatBuffers
import Foundation

// MARK - SQLiteValue for Enumerations

extension MyGame.SampleV2.Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension MyGame.SampleV2.Equipment: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    switch self {
    case .weapon(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .orb(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .empty(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: zzz_DflatGen_MyGame_SampleV2_Equipment {
    switch self {
    case .weapon(_):
      return zzz_DflatGen_MyGame_SampleV2_Equipment.weapon
    case .orb(_):
      return zzz_DflatGen_MyGame_SampleV2_Equipment.orb
    case .empty(_):
      return zzz_DflatGen_MyGame_SampleV2_Equipment.empty
    }
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: zzz_DflatGen_MyGame_SampleV2_Equipment {
    self.map { $0._type } ?? .none_
  }
}

extension MyGame.SampleV2.Vec3: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    flatBufferBuilder.create(struct: zzz_DflatGen_MyGame_SampleV2_Vec3(self))
  }
}

extension zzz_DflatGen_MyGame_SampleV2_Vec3 {
  init(_ obj: MyGame.SampleV2.Vec3) {
    self.init(x: obj.x, y: obj.y, z: obj.z)
  }
  init?(_ obj: MyGame.SampleV2.Vec3?) {
    guard let obj = obj else { return nil }
    self.init(obj)
  }
}

extension MyGame.SampleV2.Empty: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    let start = zzz_DflatGen_MyGame_SampleV2_Empty.startEmpty(&flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV2_Empty.endEmpty(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Empty {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Weapon: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset()
    let start = zzz_DflatGen_MyGame_SampleV2_Weapon.startWeapon(&flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Weapon.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Weapon.add(damage: self.damage, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV2_Weapon.endWeapon(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Orb: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset()
    let __color = zzz_DflatGen_MyGame_SampleV2_Color(rawValue: self.color.rawValue) ?? .red
    let start = zzz_DflatGen_MyGame_SampleV2_Orb.startOrb(&flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Orb.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Orb.add(color: __color, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV2_Orb.endOrb(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Monster: FlatBuffersEncodable {
  public func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    let __name = flatBufferBuilder.create(string: self.name)
    let __color = zzz_DflatGen_MyGame_SampleV2_Color(rawValue: self.color.rawValue) ?? .blue
    let __vector_inventory = flatBufferBuilder.createVector(self.inventory)
    var __weapons = [Offset]()
    for i in self.weapons {
      __weapons.append(i.to(flatBufferBuilder: &flatBufferBuilder))
    }
    let __vector_weapons = flatBufferBuilder.createVector(ofOffsets: __weapons)
    let __equippedType = self.equipped._type
    let __equipped = self.equipped.to(flatBufferBuilder: &flatBufferBuilder)
    var __colors = [zzz_DflatGen_MyGame_SampleV2_Color]()
    for i in self.colors {
      __colors.append(zzz_DflatGen_MyGame_SampleV2_Color(rawValue: i.rawValue) ?? .red)
    }
    let __vector_colors = flatBufferBuilder.createVector(__colors)
    zzz_DflatGen_MyGame_SampleV2_Monster.startVectorOfPath(self.path.count, in: &flatBufferBuilder)
    for i in self.path {
      _ = flatBufferBuilder.create(struct: zzz_DflatGen_MyGame_SampleV2_Vec3(i))
    }
    let __vector_path = flatBufferBuilder.endVector(len: self.path.count)
    let __wearType = self.wear._type
    let __wear = self.wear.to(flatBufferBuilder: &flatBufferBuilder)
    let start = zzz_DflatGen_MyGame_SampleV2_Monster.startMonster(&flatBufferBuilder)
    let __pos = zzz_DflatGen_MyGame_SampleV2_Vec3(self.pos)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(pos: __pos, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(mana: self.mana, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(hp: self.hp, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(name: __name, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(color: __color, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.addVectorOf(inventory: __vector_inventory, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.addVectorOf(weapons: __vector_weapons, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(equippedType: __equippedType, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(equipped: __equipped, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.addVectorOf(colors: __vector_colors, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.addVectorOf(path: __vector_path, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(wearType: __wearType, &flatBufferBuilder)
    zzz_DflatGen_MyGame_SampleV2_Monster.add(wear: __wear, &flatBufferBuilder)
    return zzz_DflatGen_MyGame_SampleV2_Monster.endMonster(&flatBufferBuilder, start: start)
  }
}

extension Optional where Wrapped == MyGame.SampleV2.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.SampleV2.Monster {
  public func toData() -> Data {
    var fbb = FlatBufferBuilder()
    let offset = to(flatBufferBuilder: &fbb)
    fbb.finish(offset: offset)
    return fbb.data
  }
}

// MARK - ChangeRequest

extension MyGame.SampleV2 {

public final class MonsterChangeRequest: Dflat.ChangeRequest {
  private var _o: Monster?
  public static var atomType: Any.Type { Monster.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var pos: MyGame.SampleV2.Vec3?
  public var mana: Int16
  public var hp: Int16
  public var name: String
  public var color: MyGame.SampleV2.Color
  public var inventory: [UInt8]
  public var weapons: [MyGame.SampleV2.Weapon]
  public var equipped: MyGame.SampleV2.Equipment?
  public var colors: [MyGame.SampleV2.Color]
  public var path: [MyGame.SampleV2.Vec3]
  public var wear: MyGame.SampleV2.Equipment?
  private init(type _type: ChangeRequestType) {
    _o = nil
    self._type = _type
    _rowid = -1
    pos = nil
    mana = 150
    hp = 100
    name = ""
    color = .blue
    inventory = []
    weapons = []
    equipped = nil
    colors = []
    path = []
    wear = nil
  }
  private init(type _type: ChangeRequestType, _ _o: Monster) {
    self._o = _o
    self._type = _type
    _rowid = _o._rowid
    pos = _o.pos
    mana = _o.mana
    hp = _o.hp
    name = _o.name
    color = _o.color
    inventory = _o.inventory
    weapons = _o.weapons
    equipped = _o.equipped
    colors = _o.colors
    path = _o.path
    wear = _o.wear
  }
  public static func changeRequest(_ o: Monster) -> MonsterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
    return u.map { MonsterChangeRequest(type: .update, $0) }
  }
  public static func upsertRequest(_ o: Monster) -> MonsterChangeRequest {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    guard let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key) else {
      return Self.creationRequest(o)
    }
    let changeRequest = MonsterChangeRequest(type: .update, o)
    changeRequest._o = u
    changeRequest._rowid = u._rowid
    return changeRequest
  }
  public static func creationRequest(_ o: Monster) -> MonsterChangeRequest {
    let creationRequest = MonsterChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  public static func creationRequest() -> MonsterChangeRequest {
    return MonsterChangeRequest(type: .creation)
  }
  public static func deletionRequest(_ o: Monster) -> MonsterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
    return u.map { MonsterChangeRequest(type: .deletion, $0) }
  }
  var _atom: Monster {
    let atom = Monster(name: name, color: color, pos: pos, mana: mana, hp: hp, inventory: inventory, weapons: weapons, equipped: equipped, colors: colors, path: path, wear: wear)
    atom._rowid = _rowid
    return atom
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      let indexSurvey = toolbox.connection.indexSurvey(Monster.indexFields, table: Monster.table)
      guard let insert = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster_v1_1 (__pk0, __pk1, p) VALUES (?1, ?2, ?3)") else { return nil }
      name.bindSQLite(insert, parameterId: 1)
      color.bindSQLite(insert, parameterId: 2)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(insert, 3, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      guard SQLITE_DONE == sqlite3_step(insert) else { return nil }
      _rowid = sqlite3_last_insert_rowid(toolbox.connection.sqlite)
      if indexSurvey.full.contains("f6") {
        guard let i0 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster_v1_1__f6 (rowid, f6) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i0, parameterId: 1)
        if let r0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(atom)) {
          r0.bindSQLite(i0, parameterId: 2)
        } else {
          sqlite3_bind_null(i0, 2)
        }
        guard SQLITE_DONE == sqlite3_step(i0) else { return nil }
      }
      if indexSurvey.full.contains("f8") {
        guard let i1 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster_v1_1__f8 (rowid, f8) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i1, parameterId: 1)
        if let r1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(atom)) {
          r1.bindSQLite(i1, parameterId: 2)
        } else {
          sqlite3_bind_null(i1, 2)
        }
        guard SQLITE_DONE == sqlite3_step(i1) else { return nil }
      }
      if indexSurvey.full.contains("f26__type") {
        guard let i2 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster_v1_1__f26__type (rowid, f26__type) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i2, parameterId: 1)
        if let r2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(atom)) {
          r2.bindSQLite(i2, parameterId: 2)
        } else {
          sqlite3_bind_null(i2, 2)
        }
        guard SQLITE_DONE == sqlite3_step(i2) else { return nil }
      }
      if indexSurvey.full.contains("f26__u2__f4") {
        guard let i3 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster_v1_1__f26__u2__f4 (rowid, f26__u2__f4) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i3, parameterId: 1)
        if let r3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom)) {
          r3.bindSQLite(i3, parameterId: 2)
        } else {
          sqlite3_bind_null(i3, 2)
        }
        guard SQLITE_DONE == sqlite3_step(i3) else { return nil }
      }
      if indexSurvey.full.contains("f34__u2__f4") {
        guard let i4 = toolbox.connection.prepareStaticStatement("INSERT INTO mygame__samplev2__monster_v1_1__f34__u2__f4 (rowid, f34__u2__f4) VALUES (?1, ?2)") else { return nil }
        _rowid.bindSQLite(i4, parameterId: 1)
        if let r4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom)) {
          r4.bindSQLite(i4, parameterId: 2)
        } else {
          sqlite3_bind_null(i4, 2)
        }
        guard SQLITE_DONE == sqlite3_step(i4) else { return nil }
      }
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let o = _o else { return nil }
      let atom = self._atom
      guard atom != o else {
        _type = .none
        return .identity(atom)
      }
      let indexSurvey = toolbox.connection.indexSurvey(Monster.indexFields, table: Monster.table)
      guard let update = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster_v1_1 (__pk0, __pk1, p, rowid) VALUES (?1, ?2, ?3, ?4)") else { return nil }
      name.bindSQLite(update, parameterId: 1)
      color.bindSQLite(update, parameterId: 2)
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 3, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 4)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      if indexSurvey.full.contains("f6") {
        let or0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(o))
        let r0 = MyGame.SampleV2.Monster.mana.evaluate(object: .object(atom))
        if or0 != r0 {
          guard let u0 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster_v1_1__f6 (rowid, f6) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u0, parameterId: 1)
          if let ur0 = r0 {
            ur0.bindSQLite(u0, parameterId: 2)
          } else {
            sqlite3_bind_null(u0, 2)
          }
          guard SQLITE_DONE == sqlite3_step(u0) else { return nil }
        }
      }
      if indexSurvey.full.contains("f8") {
        let or1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(o))
        let r1 = MyGame.SampleV2.Monster.hp.evaluate(object: .object(atom))
        if or1 != r1 {
          guard let u1 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster_v1_1__f8 (rowid, f8) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u1, parameterId: 1)
          if let ur1 = r1 {
            ur1.bindSQLite(u1, parameterId: 2)
          } else {
            sqlite3_bind_null(u1, 2)
          }
          guard SQLITE_DONE == sqlite3_step(u1) else { return nil }
        }
      }
      if indexSurvey.full.contains("f26__type") {
        let or2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(o))
        let r2 = MyGame.SampleV2.Monster.equipped._type.evaluate(object: .object(atom))
        if or2 != r2 {
          guard let u2 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster_v1_1__f26__type (rowid, f26__type) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u2, parameterId: 1)
          if let ur2 = r2 {
            ur2.bindSQLite(u2, parameterId: 2)
          } else {
            sqlite3_bind_null(u2, 2)
          }
          guard SQLITE_DONE == sqlite3_step(u2) else { return nil }
        }
      }
      if indexSurvey.full.contains("f26__u2__f4") {
        let or3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(o))
        let r3 = MyGame.SampleV2.Monster.equipped.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
        if or3 != r3 {
          guard let u3 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster_v1_1__f26__u2__f4 (rowid, f26__u2__f4) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u3, parameterId: 1)
          if let ur3 = r3 {
            ur3.bindSQLite(u3, parameterId: 2)
          } else {
            sqlite3_bind_null(u3, 2)
          }
          guard SQLITE_DONE == sqlite3_step(u3) else { return nil }
        }
      }
      if indexSurvey.full.contains("f34__u2__f4") {
        let or4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(o))
        let r4 = MyGame.SampleV2.Monster.wear.as(MyGame.SampleV2.Orb.self).name.evaluate(object: .object(atom))
        if or4 != r4 {
          guard let u4 = toolbox.connection.prepareStaticStatement("REPLACE INTO mygame__samplev2__monster_v1_1__f34__u2__f4 (rowid, f34__u2__f4) VALUES (?1, ?2)") else { return nil }
          _rowid.bindSQLite(u4, parameterId: 1)
          if let ur4 = r4 {
            ur4.bindSQLite(u4, parameterId: 2)
          } else {
            sqlite3_bind_null(u4, 2)
          }
          guard SQLITE_DONE == sqlite3_step(u4) else { return nil }
        }
      }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard let deletion = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster_v1_1 WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      if let d0 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster_v1_1__f6 WHERE rowid=?1") {
        _rowid.bindSQLite(d0, parameterId: 1)
        sqlite3_step(d0)
      }
      if let d1 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster_v1_1__f8 WHERE rowid=?1") {
        _rowid.bindSQLite(d1, parameterId: 1)
        sqlite3_step(d1)
      }
      if let d2 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster_v1_1__f26__type WHERE rowid=?1") {
        _rowid.bindSQLite(d2, parameterId: 1)
        sqlite3_step(d2)
      }
      if let d3 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster_v1_1__f26__u2__f4 WHERE rowid=?1") {
        _rowid.bindSQLite(d3, parameterId: 1)
        sqlite3_step(d3)
      }
      if let d4 = toolbox.connection.prepareStaticStatement("DELETE FROM mygame__samplev2__monster_v1_1__f34__u2__f4 WHERE rowid=?1") {
        _rowid.bindSQLite(d4, parameterId: 1)
        sqlite3_step(d4)
      }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}

}

// MARK - MyGame.SampleV2
