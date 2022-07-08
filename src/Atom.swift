import FlatBuffers

public protocol Atom: FlatBuffersDecodable {
  var _rowid: Int64 { get set }
  var _changesTimestamp: Int64 { get set }
}
