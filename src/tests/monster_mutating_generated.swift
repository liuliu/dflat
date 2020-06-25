import Dflat
import SQLiteDflat
import SQLite3
import FlatBuffers

// MARK - SQLiteValue for Enumerations

extension MyGame.Sample.Color: SQLiteValue {
  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {
    self.rawValue.bindSQLite(query, parameterId: parameterId)
  }
}

// MARK - Serializer

extension MyGame.Sample.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    case .weapon(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    case .orb(let o):
      return o.to(flatBufferBuilder: &flatBufferBuilder)
    }
  }
  var _type: FlatBuffers_Generated.MyGame.Sample.Equipment {
    switch self {
    case .weapon(_):
      return FlatBuffers_Generated.MyGame.Sample.Equipment.weapon
    case .orb(_):
      return FlatBuffers_Generated.MyGame.Sample.Equipment.orb
    }
  }
}

extension Optional where Wrapped == MyGame.Sample.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: FlatBuffers_Generated.MyGame.Sample.Equipment {
    self.map { $0._type } ?? .none_
  }
}

extension MyGame.Sample.Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer {
    return FlatBuffers_Generated.MyGame.Sample.createVec3(x: self.x, y: self.y, z: self.z)
  }
}

extension Optional where Wrapped == MyGame.Sample.Vec3 {
  func toRawMemory() -> UnsafeMutableRawPointer? {
    self.map { $0.toRawMemory() }
  }
}

extension MyGame.Sample.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    return FlatBuffers_Generated.MyGame.Sample.Weapon.createWeapon(&flatBufferBuilder, offsetOfName: __name, damage: self.damage)
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
    let __color = FlatBuffers_Generated.MyGame.Sample.Color(rawValue: self.color.rawValue) ?? .red
    return FlatBuffers_Generated.MyGame.Sample.Orb.createOrb(&flatBufferBuilder, offsetOfName: __name, color: __color)
  }
}

extension Optional where Wrapped == MyGame.Sample.Orb {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.Sample.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let __pos = self.pos.toRawMemory()
    let __name = flatBufferBuilder.create(string: self.name)
    let __color = FlatBuffers_Generated.MyGame.Sample.Color(rawValue: self.color.rawValue) ?? .blue
    let __inventory = flatBufferBuilder.createVector(self.inventory)
    var __bagType = [FlatBuffers_Generated.MyGame.Sample.Equipment]()
    for i in self.bag {
      __bagType.append(i._type)
    }
    let __vector_bagType = flatBufferBuilder.createVector(__bagType)
    var __bag = [Offset<UOffset>]()
    for i in self.bag {
      __bag.append(i.to(flatBufferBuilder: &flatBufferBuilder))
    }
    let __vector_bag = flatBufferBuilder.createVector(ofOffsets: __bag)
    var __weapons = [Offset<UOffset>]()
    for i in self.weapons {
      __weapons.append(i.to(flatBufferBuilder: &flatBufferBuilder))
    }
    let __vector_weapons = flatBufferBuilder.createVector(ofOffsets: __weapons)
    let __equippedType = self.equipped._type
    let __equipped = self.equipped.to(flatBufferBuilder: &flatBufferBuilder)
    var __colors = [FlatBuffers_Generated.MyGame.Sample.Color]()
    for i in self.colors {
      __colors.append(FlatBuffers_Generated.MyGame.Sample.Color(rawValue: i.rawValue) ?? .red)
    }
    let __vector_colors = flatBufferBuilder.createVector(__colors)
    var __path = [UnsafeMutableRawPointer]()
    for i in self.path {
      __path.append(i.toRawMemory())
    }
    let __vector_path = flatBufferBuilder.createVector(structs: __path, type: FlatBuffers_Generated.MyGame.Sample.Vec3.self)
    return FlatBuffers_Generated.MyGame.Sample.Monster.createMonster(&flatBufferBuilder, structOfPos: __pos, mana: self.mana, hp: self.hp, offsetOfName: __name, color: __color, vectorOfInventory: __inventory, vectorOfBagType: __vector_bagType, vectorOfBag: __vector_bag, vectorOfWeapons: __vector_weapons, equippedType: __equippedType, offsetOfEquipped: __equipped, vectorOfColors: __vector_colors, vectorOfPath: __vector_path)
  }
}

extension Optional where Wrapped == MyGame.Sample.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

// MARK - ChangeRequest

extension MyGame.Sample.Monster: SQLiteDflat.SQLiteAtom {
  public static var table: String { "mygame__sample__monster" }
  public static var indexFields: [String] { ["mana"] }
}

extension MyGame.Sample {

public final class MonsterChangeRequest: Dflat.ChangeRequest {
  public static var atomType: Any.Type { Monster.self }
  public var _type: ChangeRequestType
  public var _rowid: Int64
  public var pos: Vec3?
  public var mana: Int16
  public var hp: Int16
  public var name: String
  public var color: Color
  public var inventory: [UInt8]
  public var bag: [Equipment]
  public var weapons: [Weapon]
  public var equipped: Equipment?
  public var colors: [Color]
  public var path: [Vec3]
  public init(type: ChangeRequestType) {
    _type = type
    _rowid = -1
    pos = nil
    mana = 150
    hp = 100
    name = ""
    color = .blue
    inventory = []
    bag = []
    weapons = []
    equipped = nil
    colors = []
    path = []
  }
  public init(type: ChangeRequestType, _ o: Monster) {
    _type = type
    _rowid = o._rowid
    pos = o.pos
    mana = o.mana
    hp = o.hp
    name = o.name
    color = o.color
    inventory = o.inventory
    bag = o.bag
    weapons = o.weapons
    equipped = o.equipped
    colors = o.colors
    path = o.path
  }
  static public func changeRequest(_ o: Monster) -> MonsterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
    return u.map { MonsterChangeRequest(type: .update, $0) }
  }
  static public func creationRequest(_ o: Monster) -> MonsterChangeRequest {
    let creationRequest = MonsterChangeRequest(type: .creation, o)
    creationRequest._rowid = -1
    return creationRequest
  }
  static public func creationRequest() -> MonsterChangeRequest {
    return MonsterChangeRequest(type: .creation)
  }
  static public func deletionRequest(_ o: Monster) -> MonsterChangeRequest? {
    let transactionContext = SQLiteTransactionContext.current!
    let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey([o.name, o.color])
    let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
    return u.map { MonsterChangeRequest(type: .deletion, $0) }
  }
  var _atom: Monster {
    let atom = Monster(name: name, color: color, pos: pos, mana: mana, hp: hp, inventory: inventory, bag: bag, weapons: weapons, equipped: equipped, colors: colors, path: path)
    atom._rowid = _rowid
    return atom
  }
  static public func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__sample__monster (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, __pk1 INTEGER, p BLOB, UNIQUE(__pk0, __pk1))", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__sample__monster__mana (rowid INTEGER PRIMARY KEY, mana INTEGER)", nil, nil, nil)
    sqlite3_exec(sqlite.sqlite, "CREATE INDEX index__mygame__sample__monster__mana ON mygame__sample__monster__mana (mana)", nil, nil, nil)
  }
  public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
    guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
    switch _type {
    case .creation:
      guard let insert = toolbox.connection.prepareStatement("INSERT INTO mygame__sample__monster (__pk0, __pk1, p) VALUES (?1, ?2, ?3)") else { return nil }
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
      guard let i0 = toolbox.connection.prepareStatement("INSERT INTO mygame__sample__monster__mana (rowid, mana) VALUES (?1, ?2)") else { return nil }
      _rowid.bindSQLite(i0, parameterId: 1)
      let r0 = MyGame.Sample.Monster.mana.evaluate(object: .object(atom))
      if r0.unknown {
        sqlite3_bind_null(i0, 2)
      } else {
        r0.result.bindSQLite(i0, parameterId: 2)
      }
      guard SQLITE_DONE == sqlite3_step(i0) else { return nil }
      _type = .none
      atom._rowid = _rowid
      return .inserted(atom)
    case .update:
      guard let update = toolbox.connection.prepareStatement("UPDATE mygame__sample__monster SET __pk0=?1, __pk1=?2, p=?3 WHERE rowid=?4 LIMIT 1") else { return nil }
      name.bindSQLite(update, parameterId: 1)
      color.bindSQLite(update, parameterId: 2)
      let atom = self._atom
      toolbox.flatBufferBuilder.clear()
      let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
      toolbox.flatBufferBuilder.finish(offset: offset)
      let byteBuffer = toolbox.flatBufferBuilder.buffer
      let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
      let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
      sqlite3_bind_blob(update, 3, memory, Int32(byteBuffer.size), SQLITE_STATIC)
      _rowid.bindSQLite(update, parameterId: 4)
      guard SQLITE_DONE == sqlite3_step(update) else { return nil }
      guard let u0 = toolbox.connection.prepareStatement("UPDATE mygame__sample__monster__mana SET mana=?1 WHERE rowid=?2 LIMIT 1") else { return nil }
      _rowid.bindSQLite(u0, parameterId: 2)
      let r0 = MyGame.Sample.Monster.mana.evaluate(object: .object(atom))
      if r0.unknown {
        sqlite3_bind_null(u0, 1)
      } else {
        r0.result.bindSQLite(u0, parameterId: 1)
      }
      guard SQLITE_DONE == sqlite3_step(u0) else { return nil }
      _type = .none
      return .updated(atom)
    case .deletion:
      guard let deletion = toolbox.connection.prepareStatement("DELETE FROM mygame__sample__monster WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(deletion, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
      guard let d0 = toolbox.connection.prepareStatement("DELETE FROM mygame__sample__monster__mana WHERE rowid=?1") else { return nil }
      _rowid.bindSQLite(d0, parameterId: 1)
      guard SQLITE_DONE == sqlite3_step(d0) else { return nil }
      _type = .none
      return .deleted(_rowid)
    case .none:
      preconditionFailure()
    }
  }
}

}

// MARK - MyGame.Sample
