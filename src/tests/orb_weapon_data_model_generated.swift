import Dflat
import FlatBuffers
import Foundation
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

  public struct Weapon: Equatable, FlatBuffersDecodable {
    public var name: String?
    public var damage: Int16
    public init(name: String? = nil, damage: Int16? = 0) {
      self.name = name ?? nil
      self.damage = damage ?? 0
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Weapon) {
      self.name = obj.name
      self.damage = obj.damage
    }
    public static func from(byteBuffer bb: ByteBuffer) -> Self {
      Self(zzz_DflatGen_MyGame_Sample_Weapon.getRootAsWeapon(bb: bb))
    }
    public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
      do {
        var bb = bb
        var verifier = try Verifier(buffer: &bb)
        try ForwardOffset<zzz_DflatGen_MyGame_Sample_Weapon>.verify(
          &verifier, at: 0, of: zzz_DflatGen_MyGame_Sample_Weapon.self)
        return true
      } catch {
        return false
      }
    }
  }

  public struct Orb: Equatable, FlatBuffersDecodable {
    public var name: String?
    public var color: MyGame.Sample.Color
    public init(name: String? = nil, color: MyGame.Sample.Color? = .red) {
      self.name = name ?? nil
      self.color = color ?? .red
    }
    public init(_ obj: zzz_DflatGen_MyGame_Sample_Orb) {
      self.name = obj.name
      self.color = MyGame.Sample.Color(rawValue: obj.color.rawValue) ?? .red
    }
    public static func from(byteBuffer bb: ByteBuffer) -> Self {
      Self(zzz_DflatGen_MyGame_Sample_Orb.getRootAsOrb(bb: bb))
    }
    public static func verify(byteBuffer bb: ByteBuffer) -> Bool {
      do {
        var bb = bb
        var verifier = try Verifier(buffer: &bb)
        try ForwardOffset<zzz_DflatGen_MyGame_Sample_Orb>.verify(
          &verifier, at: 0, of: zzz_DflatGen_MyGame_Sample_Orb.self)
        return true
      } catch {
        return false
      }
    }
  }

}

// MARK: - MyGame.Sample
