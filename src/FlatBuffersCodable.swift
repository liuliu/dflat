import FlatBuffers

public protocol FlatBuffersDecodable {
  static func from(byteBuffer: ByteBuffer) -> Self
}

public protocol FlatBuffersEncodable {
  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset
}

public typealias FlatBuffersCodable = FlatBuffersDecodable & FlatBuffersEncodable
