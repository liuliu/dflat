import Dflat
import FlatBuffers
import Foundation
import SQLite3
import SQLiteDflat

extension Character {

  public enum Episode: Int32, DflatFriendlyValue {
    case newhope = 0
    case empire = 1
    case jedi = 2
    public static func < (lhs: Episode, rhs: Episode) -> Bool {
      return lhs.rawValue < rhs.rawValue
    }
  }

  public enum Subtype: Equatable {
    case human(_: Human)
    case droid(_: Droid)
  }

  public struct Droid: Equatable {
    public var appearsIn: [Character.Episode]
    public var friends: [String]
    public var name: String?
    public var primaryFunction: String?
    public init(
      appearsIn: [Character.Episode] = [], friends: [String] = [], name: String? = nil,
      primaryFunction: String? = nil
    ) {
      self.appearsIn = appearsIn
      self.friends = friends
      self.name = name
      self.primaryFunction = primaryFunction
    }
    public init(_ obj: zzz_DflatGen_Character_Droid) {
      var __appearsIn = [Character.Episode]()
      for i: Int32 in 0..<obj.appearsInCount {
        guard let o = obj.appearsIn(at: i) else { break }
        __appearsIn.append(Character.Episode(rawValue: o.rawValue) ?? .newhope)
      }
      self.appearsIn = __appearsIn
      var __friends = [String]()
      for i: Int32 in 0..<obj.friendsCount {
        guard let o = obj.friends(at: i) else { break }
        __friends.append(String(o))
      }
      self.friends = __friends
      self.name = obj.name
      self.primaryFunction = obj.primaryFunction
    }
  }

  public struct Human: Equatable {
    public var appearsIn: [Character.Episode]
    public var friends: [String]
    public var height: Double
    public var homePlanet: String?
    public var name: String?
    public init(
      appearsIn: [Character.Episode] = [], friends: [String] = [], height: Double = 0.0,
      homePlanet: String? = nil, name: String? = nil
    ) {
      self.appearsIn = appearsIn
      self.friends = friends
      self.height = height
      self.homePlanet = homePlanet
      self.name = name
    }
    public init(_ obj: zzz_DflatGen_Character_Human) {
      var __appearsIn = [Character.Episode]()
      for i: Int32 in 0..<obj.appearsInCount {
        guard let o = obj.appearsIn(at: i) else { break }
        __appearsIn.append(Character.Episode(rawValue: o.rawValue) ?? .newhope)
      }
      self.appearsIn = __appearsIn
      var __friends = [String]()
      for i: Int32 in 0..<obj.friendsCount {
        guard let o = obj.friends(at: i) else { break }
        __friends.append(String(o))
      }
      self.friends = __friends
      self.height = obj.height
      self.homePlanet = obj.homePlanet
      self.name = obj.name
    }
  }

}

// MARK: - Character

public final class Character: Dflat.Atom, SQLiteDflat.SQLiteAtom, Equatable {
  public static func == (lhs: Character, rhs: Character) -> Bool {
    guard lhs.subtype == rhs.subtype else { return false }
    guard lhs.id == rhs.id else { return false }
    return true
  }
  public let subtype: Character.Subtype?
  public let id: String
  public init(id: String, subtype: Character.Subtype? = nil) {
    self.subtype = subtype
    self.id = id
  }
  public init(_ obj: zzz_DflatGen_Character) {
    switch obj.subtypeType {
    case .none_:
      self.subtype = nil
    case .human:
      self.subtype = obj.subtype(type: zzz_DflatGen_Character_Human.self).map { .human(Human($0)) }
    case .droid:
      self.subtype = obj.subtype(type: zzz_DflatGen_Character_Droid.self).map { .droid(Droid($0)) }
    }
    self.id = obj.id!
  }
  public static func from(data: Data) -> Self {
    return data.withUnsafeBytes { buffer in
      let bb = ByteBuffer(
        assumingMemoryBound: UnsafeMutableRawPointer(mutating: buffer.baseAddress!),
        capacity: buffer.count)
      return Self(zzz_DflatGen_Character.getRootAsCharacter(bb: bb))
    }
  }
  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    Self(zzz_DflatGen_Character.getRootAsCharacter(bb: bb))
  }
  public static var table: String { "character" }
  public static var indexFields: [String] { [] }
  public static func setUpSchema(_ toolbox: PersistenceToolbox) {
    guard let sqlite = ((toolbox as? SQLitePersistenceToolbox).map { $0.connection }) else {
      return
    }
    sqlite3_exec(
      sqlite.sqlite,
      "CREATE TABLE IF NOT EXISTS character (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk0 TEXT, p BLOB, UNIQUE(__pk0))",
      nil, nil, nil)
  }
  public static func insertIndex(
    _ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer
  ) -> Bool {
    return true
  }
}
