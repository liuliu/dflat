public protocol SQLiteAtom {
  static var table: String { get }
  static var indexFields: [String] { get }
}
