import FlatBuffers

public protocol FlatBuffersDecodable {
  static func from(byteBuffer: ByteBuffer) -> Self
  static func verify(byteBuffer: ByteBuffer) -> Bool
}

public protocol FlatBuffersEncodable {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset
}

public typealias FlatBuffersCodable = FlatBuffersDecodable & FlatBuffersEncodable
