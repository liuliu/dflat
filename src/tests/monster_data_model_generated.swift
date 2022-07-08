import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

extension MyGame.Sample {

  public enum Equipment: Equatable {
    case weapon(_: Weapon)
    case orb(_: Orb)
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
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Vec3) {
      self.x = obj.x
      self.y = obj.y
      self.z = obj.z
    }

    public static func from(byteBuffer bb: ByteBuffer) -> Self {
      // Assuming this is the root
      Self(
        bb.read(
          def: zzz_DflatGen_MyGame_Sample_Vec3.self,
          position: Int(bb.read(def: UOffset.self, position: bb.reader)) + bb.reader))
    }

    public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
      do {
        var bb = bb
        var verifier = try Verifier(buffer: &bb)
        try ForwardOffset<zzz_DflatGen_MyGame_Sample_Vec3>.verify(
          &verifier, at: 0, of: zzz_DflatGen_MyGame_Sample_Vec3.self)
        return true
      } catch {
        return false
      }
    }

    public static var flatBuffersSchemaVersion: String? {
      return nil
    }
  }

  public struct Profile: Equatable, FlatBuffersDecodable {
    public var url: String?
    public init(url: String? = nil) {
      self.url = url ?? nil
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Profile) {
      self.url = obj.url
    }

    public static func from(byteBuffer bb: ByteBuffer) -> Self {
      Self(zzz_DflatGen_MyGame_Sample_Profile.getRootAsProfile(bb: bb))
    }

    public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
      do {
        var bb = bb
        var verifier = try Verifier(buffer: &bb)
        try ForwardOffset<zzz_DflatGen_MyGame_Sample_Profile>.verify(
          &verifier, at: 0, of: zzz_DflatGen_MyGame_Sample_Profile.self)
        return true
      } catch {
        return false
      }
    }

    public static var flatBuffersSchemaVersion: String? {
      return nil
    }
  }

  public final class Monster: Dflat.Atom, SQLiteDflat.SQLiteAtom, FlatBuffersDecodable, Equatable {
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
    public var _rowid: Int64 = -1
    public var _changesTimestamp: Int64 = -1
    public let pos: MyGame.Sample.Vec3?
    public let mana: Int16
    public let hp: Int16
    public let name: String
    public let color: MyGame.Sample.Color
    public let inventory: [UInt8]
    public let bag: [MyGame.Sample.Equipment]
    public let weapons: [MyGame.Sample.Weapon]
    public let equipped: MyGame.Sample.Equipment?
    public let colors: [MyGame.Sample.Color]
    public let path: [MyGame.Sample.Vec3]
    public let hpOld: Int16
    public let profile: MyGame.Sample.Profile?
    public let type: Bool
    public let truth: Bool
    public init(
      name: String, color: MyGame.Sample.Color, pos: MyGame.Sample.Vec3? = nil, mana: Int16? = 150,
      hp: Int16? = 100, inventory: [UInt8]? = [], bag: [MyGame.Sample.Equipment]? = [],
      weapons: [MyGame.Sample.Weapon]? = [], equipped: MyGame.Sample.Equipment? = nil,
      colors: [MyGame.Sample.Color]? = [], path: [MyGame.Sample.Vec3]? = [], hpOld: Int16? = 200,
      profile: MyGame.Sample.Profile? = nil, type: Bool? = false, truth: Bool? = true
    ) {
      self.pos = pos ?? nil
      self.mana = mana ?? 150
      self.hp = hp ?? 100
      self.name = name
      self.color = color
      self.inventory = inventory ?? []
      self.bag = bag ?? []
      self.weapons = weapons ?? []
      self.equipped = equipped ?? nil
      self.colors = colors ?? []
      self.path = path ?? []
      self.hpOld = hpOld ?? 200
      self.profile = profile ?? nil
      self.type = type ?? false
      self.truth = truth ?? true
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Monster) {
      self.pos = obj.pos.map { MyGame.Sample.Vec3($0) }
      self.mana = obj.mana
      self.hp = obj.hp
      self.name = obj.name!
      self.color = MyGame.Sample.Color(rawValue: obj.color.rawValue) ?? .blue
      self.inventory = obj.inventory
      var __bag = [MyGame.Sample.Equipment]()
      for i: Int32 in 0..<obj.bagCount {
        guard let ot = obj.bagType(at: i) else { break }
        switch ot {
        case .none_:
          continue
        case .weapon:
          guard let oe = obj.bag(at: i, type: zzz_DflatGen_MyGame_Sample_Weapon.self) else { break }
          __bag.append(.weapon(Weapon(oe)))
        case .orb:
          guard let oe = obj.bag(at: i, type: zzz_DflatGen_MyGame_Sample_Orb.self) else { break }
          __bag.append(.orb(Orb(oe)))
        }
      }
      self.bag = __bag
      var __weapons = [MyGame.Sample.Weapon]()
      for i: Int32 in 0..<obj.weaponsCount {
        guard let o = obj.weapons(at: i) else { break }
        __weapons.append(MyGame.Sample.Weapon(o))
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
      var __colors = [MyGame.Sample.Color]()
      for i: Int32 in 0..<obj.colorsCount {
        guard let o = obj.colors(at: i) else { break }
        __colors.append(MyGame.Sample.Color(rawValue: o.rawValue) ?? .red)
      }
      self.colors = __colors
      var __path = [MyGame.Sample.Vec3]()
      for i: Int32 in 0..<obj.pathCount {
        guard let o = obj.path(at: i) else { break }
        __path.append(MyGame.Sample.Vec3(o))
      }
      self.path = __path
      self.hpOld = obj.hpOld
      self.profile = obj.profile.map { MyGame.Sample.Profile($0) }
      self.type = obj.type
      self.truth = obj.truth
    }
    public static func from(data: Data) -> Self {
      return data.withUnsafeBytes { buffer in
        let bb = ByteBuffer(
          assumingMemoryBound: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
          capacity: buffer.count)
        return Self(zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: bb))
      }
    }
    public static func from(byteBuffer bb: ByteBuffer) -> Self {
      Self(zzz_DflatGen_MyGame_Sample_Monster.getRootAsMonster(bb: bb))
    }
    public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
      do {
        var bb = bb
        var verifier = try Verifier(buffer: &bb)
        try ForwardOffset<zzz_DflatGen_MyGame_Sample_Monster>.verify(
          &verifier, at: 0, of: zzz_DflatGen_MyGame_Sample_Monster.self)
        return true
      } catch {
        return false
      }
    }
    public static var flatBuffersSchemaVersion: String? {
      return "1.1"
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
        if let retval = MyGame.Sample.Monster.mana.evaluate(byteBuffer: table) {
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
        if let retval = MyGame.Sample.Monster.equipped._type.evaluate(byteBuffer: table) {
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
          byteBuffer: table)
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
