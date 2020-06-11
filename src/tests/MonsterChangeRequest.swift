import Dflat
import SQLiteDflat
import SQLite3

extension MyGame.Sample.Monster: SQLiteDflat.SQLiteAtom {
  public static var table: String { "mygame__sample__monster" }
  public static var indexFields: [String] { [] }
}

extension MyGame.Sample {
  public final class MonsterChangeRequest: Dflat.ChangeRequest {
    public static var atomType: Any.Type { Monster.self }
    private var _type: ChangeRequestType
    private var _rowid: Int64
    public var pos: Vec3?
    public var mana: Int16
    public var hp: Int16
    public var name: String?
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
      name = nil
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
    static public func changeRequest(_ o: Monster) -> MonsterChangeRequest {
      return MonsterChangeRequest(type: .update, o)
    }
    static public func creationRequest(_ o: Monster) -> MonsterChangeRequest {
      return MonsterChangeRequest(type: .creation, o)
    }
    static public func creationRequest() -> MonsterChangeRequest {
      return MonsterChangeRequest(type: .creation)
    }
    static public func deletionRequest(_ o: Monster) -> MonsterChangeRequest {
      return MonsterChangeRequest(type: .deletion, o)
    }
    static public func setUpSchema(_ sqlite: SchemaSetUpper) {
      guard let sqlite = sqlite as? SQLiteConnection else { return }
      sqlite3_exec(sqlite.sqlite, "CREATE TABLE IF NOT EXISTS mygame__sample__monster (rowid INTEGER PRIMARY KEY AUTOINCREMENT, __pk TEXT, p BLOB, UNIQUE (__pk))", nil, nil, nil)
    }
  }
}
