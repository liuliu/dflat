import Dflat

public protocol SQLiteAtom {
  static var table: String { get }
  static var indexFields: [String] { get }
  static func setUpSchema(_ toolbox: PersistenceToolbox)
}
