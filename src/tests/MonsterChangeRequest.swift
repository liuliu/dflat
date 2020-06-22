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

extension MyGame.Sample.Monster: SQLiteDflat.SQLiteAtom {
  public static var table: String { "mygame__sample__monster" }
  public static var indexFields: [String] { [] }
}

extension MyGame.Sample.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let name = self.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
    return FlatBuffers_Generated.MyGame.Sample.Weapon.createWeapon(&flatBufferBuilder, offsetOfName: name, damage: damage)
  }
}

extension Optional where Wrapped == MyGame.Sample.Weapon {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
}

extension MyGame.Sample.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    switch self {
    case .weapon(let weapon):
      let name = weapon.name.map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()
      return FlatBuffers_Generated.MyGame.Sample.Weapon.createWeapon(&flatBufferBuilder, offsetOfName: name, damage: weapon.damage)
    }
  }
  var _type: FlatBuffers_Generated.MyGame.Sample.Equipment {
    switch self {
    case .weapon(_):
      return FlatBuffers_Generated.MyGame.Sample.Equipment.weapon
    }
  }
}

extension Optional where Wrapped == MyGame.Sample.Equipment {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()
  }
  var _type: FlatBuffers_Generated.MyGame.Sample.Equipment {
    self.map { $0._type } ?? FlatBuffers_Generated.MyGame.Sample.Equipment.none_
  }
}

extension MyGame.Sample.Monster {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {
    let name = flatBufferBuilder.create(string: self.name)
    let vectorOfInventory = flatBufferBuilder.createVector(self.inventory)
    var weapons = [Offset<UOffset>]()
    for i in self.weapons {
      weapons.append(i.to(flatBufferBuilder: &flatBufferBuilder))
    }
    let vectorOfWeapons = flatBufferBuilder.createVector(ofOffsets: weapons)
    let equippedType = self.equipped._type
    let equipped = self.equipped.to(flatBufferBuilder: &flatBufferBuilder)
    var path = [UnsafeMutableRawPointer]()
    for i in self.path {
      path.append(FlatBuffers_Generated.MyGame.Sample.createVec3(x: i.x, y: i.y, z: i.z))
    }
    let vectorOfPath = flatBufferBuilder.createVector(structs: path, type: FlatBuffers_Generated.MyGame.Sample.Vec3.self)
    let pos = self.pos.map { FlatBuffers_Generated.MyGame.Sample.createVec3(x: $0.x, y: $0.y, z: $0.z) }
    return FlatBuffers_Generated.MyGame.Sample.Monster.createMonster(&flatBufferBuilder, structOfPos: pos, mana: mana, hp: hp, offsetOfName: name, vectorOfInventory: vectorOfInventory, color: FlatBuffers_Generated.MyGame.Sample.Color(rawValue: color.rawValue) ?? .blue, vectorOfWeapons: vectorOfWeapons, equippedType: equippedType, offsetOfEquipped: equipped, vectorOfPath: vectorOfPath)
  }
}

// MARK - ChangeRequest

extension MyGame.Sample {
  public final class MonsterChangeRequest: Dflat.ChangeRequest {
    public static var atomType: Any.Type { Monster.self }
    private var _type: ChangeRequestType
    private var _rowid: Int64
    public var pos: Vec3?
    public var mana: Int16
    public var hp: Int16
    public var name: String
    public var inventory: [UInt8]
    public var color: Color
    public var weapons: [Weapon]
    public var equipped: Equipment?
    public var path: [Vec3]
    private init(type: ChangeRequestType) {
      _type = type
      _rowid = -1
      pos = nil
      mana = 150
      hp = 100
      name = ""
      inventory = []
      color = .blue
      weapons = []
      equipped = nil
      path = []
    }
    private init(type: ChangeRequestType, _ o: Monster) {
      _type = type
      _rowid = o._rowid
      pos = o.pos
      mana = o.mana
      hp = o.hp
      name = o.name
      inventory = o.inventory
      color = o.color
      weapons = o.weapons
      equipped = o.equipped
      path = o.path
    }
    static public func changeRequest(_ o: Monster) -> MonsterChangeRequest? {
      let transactionContext = SQLiteTransactionContext.current!
      let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey(o.name)
      let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
      return u.map { MonsterChangeRequest(type: .update, $0) }
    }
    static public func creationRequest(_ o: Monster) -> MonsterChangeRequest {
      let creationRequest = MonsterChangeRequest(type: .creation, o)
      creationRequest._rowid = -1 // Reset the rowid back to -1.
      return creationRequest
    }
    static public func creationRequest() -> MonsterChangeRequest {
      return MonsterChangeRequest(type: .creation)
    }
    static public func deletionRequest(_ o: Monster) -> MonsterChangeRequest? {
      let transactionContext = SQLiteTransactionContext.current!
      let key: SQLiteObjectKey = o._rowid >= 0 ? .rowid(o._rowid) : .primaryKey(o.name)
      let u = transactionContext.objectRepository.object(transactionContext.connection, ofType: Monster.self, for: key)
      return u.map { MonsterChangeRequest(type: .deletion, $0) }
    }
    static public func setUpSchema(_ toolbox: PersistenceToolbox) {
      guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else { return }
      sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__sample__monster (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk TEXT, p BLOB, UNIQUE (__pk))", nil, nil, nil)
    }
    var _atom: Monster {
      let atom = Monster(pos: pos, name: name, inventory: inventory, weapons: weapons, equipped: equipped, path: path, mana: mana, hp: hp, color: color)
      atom._rowid = _rowid
      return atom
    }
    public func commit(_ toolbox: PersistenceToolbox) -> UpdatedObject? {
      guard let toolbox = toolbox as? SQLitePersistenceToolbox else { return nil }
      switch _type {
      case .creation:
        guard let insert = toolbox.connection.prepareStatement("INSERT INTO mygame__sample__monster (__pk, p) VALUES (?1, ?2)") else { return nil }
        name.bindSQLite(insert, parameterId: 1)
        let atom = self._atom
        toolbox.flatBufferBuilder.clear()
        let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
        toolbox.flatBufferBuilder.finish(offset: offset)
        let byteBuffer = toolbox.flatBufferBuilder.buffer
        let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
        let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
        sqlite3_bind_blob(insert, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
        guard SQLITE_DONE == sqlite3_step(insert) else { return nil }
        _rowid = sqlite3_last_insert_rowid(toolbox.connection.sqlite)
        _type = .none
        atom._rowid = _rowid
        return .inserted(atom)
      case .update:
        guard let update = toolbox.connection.prepareStatement("UPDATE mygame__sample__monster set __pk=?1, p=?2 WHERE rowid=?3 LIMIT 1") else { return nil }
        name.bindSQLite(update, parameterId: 1)
        let atom = self._atom
        atom._rowid = _rowid
        toolbox.flatBufferBuilder.clear()
        let offset = atom.to(flatBufferBuilder: &toolbox.flatBufferBuilder)
        toolbox.flatBufferBuilder.finish(offset: offset)
        let byteBuffer = toolbox.flatBufferBuilder.buffer
        let memory = byteBuffer.memory.advanced(by: byteBuffer.reader)
        let SQLITE_STATIC = unsafeBitCast(OpaquePointer(bitPattern: 0), to: sqlite3_destructor_type.self)
        sqlite3_bind_blob(update, 2, memory, Int32(byteBuffer.size), SQLITE_STATIC)
        _rowid.bindSQLite(update, parameterId: 3)
        guard SQLITE_DONE == sqlite3_step(update) else { return nil }
        _type = .none
        return .updated(atom)
      case .deletion:
        guard let deletion = toolbox.connection.prepareStatement("DELETE FROM mygame__sample__monster WHERE rowid=?1") else { return nil }
        _rowid.bindSQLite(deletion, parameterId: 1)
        guard SQLITE_DONE == sqlite3_step(deletion) else { return nil }
        _type = .none
        return .deleted(_rowid)
      case .none:
        preconditionFailure()
      }
    }
  }
}
