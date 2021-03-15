import Dflat
import FlatBuffers
import SQLite3
import SQLiteDflat

extension MyGame.Sample {

  public enum Color: Int8, DflatFriendlyValue {
    case red = 0
    case green = 1
    case blue = 2
    public static func < (lhs: Color, rhs: Color) -> Bool {
      return lhs.rawValue < rhs.rawValue
    }
  }

  public struct Weapon: Equatable {
    public var name: String?
    public var damage: Int16
    public init(name: String? = nil, damage: Int16 = 0) {
      self.name = name
      self.damage = damage
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Weapon) {
      self.name = obj.name
      self.damage = obj.damage
    }
  }

  public struct Orb: Equatable {
    public var name: String?
    public var color: MyGame.Sample.Color
    public init(name: String? = nil, color: MyGame.Sample.Color = .red) {
      self.name = name
      self.color = color
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Orb) {
      self.name = obj.name
      self.color = MyGame.Sample.Color(rawValue: obj.color.rawValue) ?? .red
    }
  }

}

// MARK: - MyGame.Sample
