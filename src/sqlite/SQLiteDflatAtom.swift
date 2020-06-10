public protocol SQLiteDflatAtom {
  var table: String { get }
  var indexFields: [String] { get }
}
