import Dflat
import FlatBuffers

public protocol SQLiteAtom {
  static var table: String { get }
  static var indexFields: [String] { get }
  static func setUpSchema(_ toolbox: PersistenceToolbox)
  static func insertIndex(
    _ toolbox: PersistenceToolbox, field: String, rowid: Int64, table: ByteBuffer
  ) -> Bool
}
