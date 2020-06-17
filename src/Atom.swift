import FlatBuffers

open class Atom {
  public final var _rowid: Int64 = -1
  public final var _changesTimestamp: Int64 = -1
  public init() {}
  open class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {
    fatalError()
  }
}
