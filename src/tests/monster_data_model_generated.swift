import Dflat
import FlatBuffers
import SQLite3
import SQLiteDflat

extension MyGame.Sample {

  public enum Equipment: Equatable {
    case weapon(_: Weapon)
    case orb(_: Orb)
  }

  public struct Vec3: Equatable {
    public var x: Float32
    public var y: Float32
    public var z: Float32
    public init(x: Float32 = 0.0, y: Float32 = 0.0, z: Float32 = 0.0) {
      self.x = x
      self.y = y
      self.z = z
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Vec3) {
      self.x = obj.x
      self.y = obj.y
      self.z = obj.z
    }
  }

  public struct Profile: Equatable {
    public var url: String?
    public init(url: String? = nil) {
      self.url = url
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Profile) {
      self.url = obj.url
    }
  }

  public final class Monster: Dflat.Atom, SQLiteDflat.SQLiteAtom, Equatable {
    public static func == (lhs: Monster, rhs: Monster) -> Bool {
      guard lhs.pos == rhs.pos else { return false }
      guard lhs.mana == rhs.mana else { return false }
      guard lhs.hp == rhs.hp else { return false }
      guard lhs.name == rhs.name else { return false }
      guard lhs.color == rhs.color else { return false }
      guard lhs.inventory == rhs.inventory else { return false }
      guard lhs.bag == rhs.bag else { return false }
      guard lhs.weapons == rhs.weapons else { return false }
      guard lhs.equipped == rhs.equipped else { return false }
      guard lhs.colors == rhs.colors else { return false }
      guard lhs.path == rhs.path else { return false }
      guard lhs.hpOld == rhs.hpOld else { return false }
      guard lhs.profile == rhs.profile else { return false }
      guard lhs.type == rhs.type else { return false }
      guard lhs.truth == rhs.truth else { return false }
      return true
    }
    public let pos: Vec3?
    public let mana: Int16
    public let hp: Int16
    public let name: String
    public let color: Color
    public let inventory: [UInt8]
    public let bag: [Equipment]
    public let weapons: [Weapon]
    public let equipped: Equipment?
    public let colors: [Color]
    public let path: [Vec3]
    public let hpOld: Int16
    public let profile: Profile?
    public let type: Bool
    public let truth: Bool
    public init(
      name: String, color: Color, pos: Vec3? = nil, mana: Int16 = 150, hp: Int16 = 100,
      inventory: [UInt8] = [], bag: [Equipment] = [], weapons: [Weapon] = [],
      equipped: Equipment? = nil, colors: [Color] = [], path: [Vec3] = [], hpOld: Int16 = 200,
      profile: Profile? = nil, type: Bool = false, truth: Bool = true
    ) {
      self.pos = pos
      self.mana = mana
      self.hp = hp
      self.name = name
      self.color = color
      self.inventory = inventory
      self.bag = bag
      self.weapons = weapons
      self.equipped = equipped
      self.colors = colors
      self.path = path
      self.hpOld = hpOld
      self.profile = profile
      self.type = type
      self.truth = truth
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Monster) {
      self.pos = obj.pos.map { Vec3($0) }
      self.mana = obj.mana
      self.hp = obj.hp
      self.name = obj.name!
      self.color = Color(rawValue: obj.color.rawValue) ?? .blue
      self.inventory = obj.inventory
      var __bag = [Equipment]()
      for i: Int32 in 0..<obj.bagCount {
        guard let ot = obj.bagType(at: i) else { break }
        switch ot {
        case .none_:
          fatalError()
        case .weapon:
          guard let oe = obj.bag(at: i, type: zzz_DflatGen_MyGame_Sample_Weapon.self) else { break }
          __bag.append(.weapon(Weapon(oe)))
        case .orb:
          guard let oe = obj.bag(at: i, type: zzz_DflatGen_MyGame_Sample_Orb.self) else { break }
          __bag.append(.orb(Orb(oe)))
        }
      }
      self.bag = __bag
      var __weapons = [Weapon]()
      for i: Int32 in 0..<obj.weaponsCount {
        guard let o = obj.weapons(at: i) else { break }
        __weapons.append(Weapon(o))
      }
      self.weapons = __weapons
      switch obj.equippedType {
      case .none_:
        self.equipped = nil
      case .weapon:
        self.equipped = obj.equipped(type: zzz_DflatGen_MyGame_Sample_Weapon.self).map {
          .weapon(Weapon($0))
        }
      case .orb:
        self.equipped = obj.equipped(type: zzz_DflatGen_MyGame_Sample_Orb.self).map {
          .orb(Orb($0))
        }
      }
      var __colors = [Color]()
      for i: Int32 in 0..<obj.colorsCount {
        guard let o = obj.colors(at: i) else { break }
        __colors.append(Color(rawValue: o.rawValue) ?? .red)
      }
      self.colors = __colors
      var __path = [Vec3]()
      for i: Int32 in 0..<obj.pathCount {
        guard let o = obj.path(at: i) else { break }
        __path.append(Vec3(o))
      }
      self.path = __path
      self.hpOld = obj.hpOld
      self.profile = obj.profile.map { Profile($0) }
      self.type = obj.type
      self.truth = obj.truth
    }
    override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
      Self(zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: bb))
    }
    public static var table: String { "mygame__sample__monster_v1_1" }
    public static var indexFields: [String] { ["f6", "f26__type", "f26__u2__f4"] }
    public static func setUpSchema(_ toolbox: PersistenceToolbox) {
      guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else {
        return
      }
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE TABLE IF NOT EXISTS mygame__sample__monster_v1_1 (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, __pk1 INTEGER, p BLOB, UNIQUE(__pk0, __pk1))",
        nil, nil, nil)
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE TABLE IF NOT EXISTS mygame__sample__monster_v1_1__f6 (rowid INTEGER PRIMARY KEY, f6 INTEGER)",
        nil, nil, nil)
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE INDEX IF NOT EXISTS index__mygame__sample__monster_v1_1__f6 ON mygame__sample__monster_v1_1__f6 (f6)",
        nil, nil, nil)
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE TABLE IF NOT EXISTS mygame__sample__monster_v1_1__f26__type (rowid INTEGER PRIMARY KEY, f26__type INTEGER)",
        nil, nil, nil)
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE INDEX IF NOT EXISTS index__mygame__sample__monster_v1_1__f26__type ON mygame__sample__monster_v1_1__f26__type (f26__type)",
        nil, nil, nil)
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE TABLE IF NOT EXISTS mygame__sample__monster_v1_1__f26__u2__f4 (rowid INTEGER PRIMARY KEY, f26__u2__f4 TEXT)",
        nil, nil, nil)
      sqlite3_exec(
        sqlite.sqlite,
        "CREATE UNIQUE INDEX IF NOT EXISTS index__mygame__sample__monster_v1_1__f26__u2__f4 ON mygame__sample__monster_v1_1__f26__u2__f4 (f26__u2__f4)",
        nil, nil, nil)
      sqlite.clearIndexStatus(for: Self.table)
    }
    public static func insertIndex(
      _ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer
    ) -> Bool {
      guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else {
        return false
      }
      switch field {
      case "f6":
        guard
          let insert = sqlite.prepareStaticStatement(
            "INSERT INTO mygame__sample__monster_v1_1__f6 (rowid, f6) VALUES (?1, ?2)")
        else { return false }
        rowid.bindSQLite(insert, parameterId: 1)
        if let retval = MyGame.Sample.Monster.mana.evaluate(object: .table(table)) {
          retval.bindSQLite(insert, parameterId: 2)
        } else {
          sqlite3_bind_null(insert, 2)
        }
        guard SQLITE_DONE == sqlite3_step(insert) else { return false }
      case "f26__type":
        guard
          let insert = sqlite.prepareStaticStatement(
            "INSERT INTO mygame__sample__monster_v1_1__f26__type (rowid, f26__type) VALUES (?1, ?2)"
          )
        else { return false }
        rowid.bindSQLite(insert, parameterId: 1)
        if let retval = MyGame.Sample.Monster.equipped._type.evaluate(object: .table(table)) {
          retval.bindSQLite(insert, parameterId: 2)
        } else {
          sqlite3_bind_null(insert, 2)
        }
        guard SQLITE_DONE == sqlite3_step(insert) else { return false }
      case "f26__u2__f4":
        guard
          let insert = sqlite.prepareStaticStatement(
            "INSERT INTO mygame__sample__monster_v1_1__f26__u2__f4 (rowid, f26__u2__f4) VALUES (?1, ?2)"
          )
        else { return false }
        rowid.bindSQLite(insert, parameterId: 1)
        if let retval = MyGame.Sample.Monster.equipped.as(MyGame.Sample.Orb.self).name.evaluate(
          object: .table(table))
        {
          retval.bindSQLite(insert, parameterId: 2)
        } else {
          sqlite3_bind_null(insert, 2)
        }
        guard SQLITE_DONE == sqlite3_step(insert) else { return false }
      default:
        break
      }
      return true
    }
  }

}

// MARK: - MyGame.Sample
