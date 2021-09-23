// automatically generated by the FlatBuffers compiler, do not modify
// swiftlint:disable all
// swiftformat:disable all

import FlatBuffers

public enum zzz_DflatGen_Color: Int8, Enum, Verifiable {
  public typealias T = Int8
  public static var byteSize: Int { return MemoryLayout<Int8>.size }
  public var value: Int8 { return self.rawValue }
  case red = 0
  case green = 1
  case blue = 2

  public static var max: zzz_DflatGen_Color { return .blue }
  public static var min: zzz_DflatGen_Color { return .red }
}

public enum zzz_DflatGen_Content: UInt8, UnionEnum {
  public typealias T = UInt8

  public init?(value: T) {
    self.init(rawValue: value)
  }

  public static var byteSize: Int { return MemoryLayout<UInt8>.size }
  public var value: UInt8 { return self.rawValue }
  case none_ = 0
  case textcontent = 1
  case imagecontent = 2

  public static var max: zzz_DflatGen_Content { return .imagecontent }
  public static var min: zzz_DflatGen_Content { return .none_ }
}

public struct zzz_DflatGen_Vec3: NativeStruct, Verifiable {

  static func validateVersion() { FlatBuffersVersion_2_0_0() }

  private var _x: Float32
  private var _y: Float32
  private var _z: Float32

  public init(x: Float32, y: Float32, z: Float32) {
    _x = x
    _y = y
    _z = z
  }

  public init() {
    _x = 0.0
    _y = 0.0
    _z = 0.0
  }

  public var x: Float32 { _x }
  public var y: Float32 { _y }
  public var z: Float32 { _z }

  public static func verify<T>(_ verifier: inout Verifier, at position: Int, of type: T.Type) throws
  where T: Verifiable {
    try verifier.inBuffer(position: position, of: zzz_DflatGen_Vec3.self)
  }
}

public struct zzz_DflatGen_Vec3_Mutable: FlatBufferObject {

  static func validateVersion() { FlatBuffersVersion_2_0_0() }
  public var __buffer: ByteBuffer! { return _accessor.bb }
  private var _accessor: Struct

  public init(_ bb: ByteBuffer, o: Int32) { _accessor = Struct(bb: bb, position: o) }

  public var x: Float32 { return _accessor.readBuffer(of: Float32.self, at: 0) }
  public var y: Float32 { return _accessor.readBuffer(of: Float32.self, at: 4) }
  public var z: Float32 { return _accessor.readBuffer(of: Float32.self, at: 8) }
}

public struct zzz_DflatGen_TextContent: FlatBufferObject, Verifiable {

  static func validateVersion() { FlatBuffersVersion_2_0_0() }
  public var __buffer: ByteBuffer! { return _accessor.bb }
  private var _accessor: Table

  public static func getRootAsTextContent(bb: ByteBuffer) -> zzz_DflatGen_TextContent {
    return zzz_DflatGen_TextContent(
      Table(
        bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))
    )
  }

  private init(_ t: Table) { _accessor = t }
  public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

  private enum VTOFFSET: VOffset {
    case text = 4
    var v: Int32 { Int32(self.rawValue) }
    var p: VOffset { self.rawValue }
  }

  public var text: String? {
    let o = _accessor.offset(VTOFFSET.text.v)
    return o == 0 ? nil : _accessor.string(at: o)
  }
  public var textSegmentArray: [UInt8]? { return _accessor.getVector(at: VTOFFSET.text.v) }
  public static func startTextContent(_ fbb: inout FlatBufferBuilder) -> UOffset {
    fbb.startTable(with: 1)
  }
  public static func add(text: Offset, _ fbb: inout FlatBufferBuilder) {
    fbb.add(offset: text, at: VTOFFSET.text.p)
  }
  public static func endTextContent(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset {
    let end = Offset(offset: fbb.endTable(at: start))
    return end
  }
  public static func createTextContent(
    _ fbb: inout FlatBufferBuilder,
    textOffset text: Offset = Offset()
  ) -> Offset {
    let __start = zzz_DflatGen_TextContent.startTextContent(&fbb)
    zzz_DflatGen_TextContent.add(text: text, &fbb)
    return zzz_DflatGen_TextContent.endTextContent(&fbb, start: __start)
  }

  public static func verify<T>(_ verifier: inout Verifier, at position: Int, of type: T.Type) throws
  where T: Verifiable {
    var _v = try verifier.visitTable(at: position)
    try _v.visit(
      field: VTOFFSET.text.p, fieldName: "text", required: false, type: ForwardOffset<String>.self)
    _v.finish()
  }
}

public struct zzz_DflatGen_ImageContent: FlatBufferObject, Verifiable {

  static func validateVersion() { FlatBuffersVersion_2_0_0() }
  public var __buffer: ByteBuffer! { return _accessor.bb }
  private var _accessor: Table

  public static func getRootAsImageContent(bb: ByteBuffer) -> zzz_DflatGen_ImageContent {
    return zzz_DflatGen_ImageContent(
      Table(
        bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))
    )
  }

  private init(_ t: Table) { _accessor = t }
  public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

  private enum VTOFFSET: VOffset {
    case images = 4
    var v: Int32 { Int32(self.rawValue) }
    var p: VOffset { self.rawValue }
  }

  public var imagesCount: Int32 {
    let o = _accessor.offset(VTOFFSET.images.v)
    return o == 0 ? 0 : _accessor.vector(count: o)
  }
  public func images(at index: Int32) -> String? {
    let o = _accessor.offset(VTOFFSET.images.v)
    return o == 0 ? nil : _accessor.directString(at: _accessor.vector(at: o) + index * 4)
  }
  public static func startImageContent(_ fbb: inout FlatBufferBuilder) -> UOffset {
    fbb.startTable(with: 1)
  }
  public static func addVectorOf(images: Offset, _ fbb: inout FlatBufferBuilder) {
    fbb.add(offset: images, at: VTOFFSET.images.p)
  }
  public static func endImageContent(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset {
    let end = Offset(offset: fbb.endTable(at: start))
    return end
  }
  public static func createImageContent(
    _ fbb: inout FlatBufferBuilder,
    imagesVectorOffset images: Offset = Offset()
  ) -> Offset {
    let __start = zzz_DflatGen_ImageContent.startImageContent(&fbb)
    zzz_DflatGen_ImageContent.addVectorOf(images: images, &fbb)
    return zzz_DflatGen_ImageContent.endImageContent(&fbb, start: __start)
  }

  public static func verify<T>(_ verifier: inout Verifier, at position: Int, of type: T.Type) throws
  where T: Verifiable {
    var _v = try verifier.visitTable(at: position)
    try _v.visit(
      field: VTOFFSET.images.p, fieldName: "images", required: false,
      type: ForwardOffset<Vector<ForwardOffset<String>, String>>.self)
    _v.finish()
  }
}

public struct zzz_DflatGen_BenchDoc: FlatBufferObject, Verifiable {

  static func validateVersion() { FlatBuffersVersion_2_0_0() }
  public var __buffer: ByteBuffer! { return _accessor.bb }
  private var _accessor: Table

  public static func getRootAsBenchDoc(bb: ByteBuffer) -> zzz_DflatGen_BenchDoc {
    return zzz_DflatGen_BenchDoc(
      Table(
        bb: bb, position: Int32(bb.read(def: UOffset.self, position: bb.reader)) + Int32(bb.reader))
    )
  }

  private init(_ t: Table) { _accessor = t }
  public init(_ bb: ByteBuffer, o: Int32) { _accessor = Table(bb: bb, position: o) }

  private enum VTOFFSET: VOffset {
    case pos = 4
    case color = 6
    case title = 8
    case contentType = 10
    case content = 12
    case tag = 14
    case priority = 16
    var v: Int32 { Int32(self.rawValue) }
    var p: VOffset { self.rawValue }
  }

  public var pos: zzz_DflatGen_Vec3? {
    let o = _accessor.offset(VTOFFSET.pos.v)
    return o == 0 ? nil : _accessor.readBuffer(of: zzz_DflatGen_Vec3.self, at: o)
  }
  public var mutablePos: zzz_DflatGen_Vec3_Mutable? {
    let o = _accessor.offset(VTOFFSET.pos.v)
    return o == 0 ? nil : zzz_DflatGen_Vec3_Mutable(_accessor.bb, o: o + _accessor.postion)
  }
  public var color: zzz_DflatGen_Color {
    let o = _accessor.offset(VTOFFSET.color.v)
    return o == 0
      ? .red : zzz_DflatGen_Color(rawValue: _accessor.readBuffer(of: Int8.self, at: o)) ?? .red
  }
  public var title: String? {
    let o = _accessor.offset(VTOFFSET.title.v)
    return o == 0 ? nil : _accessor.string(at: o)
  }
  public var titleSegmentArray: [UInt8]? { return _accessor.getVector(at: VTOFFSET.title.v) }
  public var contentType: zzz_DflatGen_Content {
    let o = _accessor.offset(VTOFFSET.contentType.v)
    return o == 0
      ? .none_
      : zzz_DflatGen_Content(rawValue: _accessor.readBuffer(of: UInt8.self, at: o)) ?? .none_
  }
  public func content<T: FlatbuffersInitializable>(type: T.Type) -> T? {
    let o = _accessor.offset(VTOFFSET.content.v)
    return o == 0 ? nil : _accessor.union(o)
  }
  public var tag: String? {
    let o = _accessor.offset(VTOFFSET.tag.v)
    return o == 0 ? nil : _accessor.string(at: o)
  }
  public var tagSegmentArray: [UInt8]? { return _accessor.getVector(at: VTOFFSET.tag.v) }
  public var priority: Int32 {
    let o = _accessor.offset(VTOFFSET.priority.v)
    return o == 0 ? 0 : _accessor.readBuffer(of: Int32.self, at: o)
  }
  public static func startBenchDoc(_ fbb: inout FlatBufferBuilder) -> UOffset {
    fbb.startTable(with: 7)
  }
  public static func add(pos: zzz_DflatGen_Vec3?, _ fbb: inout FlatBufferBuilder) {
    guard let pos = pos else { return }
    fbb.create(struct: pos, position: VTOFFSET.pos.p)
  }
  public static func add(color: zzz_DflatGen_Color, _ fbb: inout FlatBufferBuilder) {
    fbb.add(element: color.rawValue, def: 0, at: VTOFFSET.color.p)
  }
  public static func add(title: Offset, _ fbb: inout FlatBufferBuilder) {
    fbb.add(offset: title, at: VTOFFSET.title.p)
  }
  public static func add(contentType: zzz_DflatGen_Content, _ fbb: inout FlatBufferBuilder) {
    fbb.add(element: contentType.rawValue, def: 0, at: VTOFFSET.contentType.p)
  }
  public static func add(content: Offset, _ fbb: inout FlatBufferBuilder) {
    fbb.add(offset: content, at: VTOFFSET.content.p)
  }
  public static func add(tag: Offset, _ fbb: inout FlatBufferBuilder) {
    fbb.add(offset: tag, at: VTOFFSET.tag.p)
  }
  public static func add(priority: Int32, _ fbb: inout FlatBufferBuilder) {
    fbb.add(element: priority, def: 0, at: VTOFFSET.priority.p)
  }
  public static func endBenchDoc(_ fbb: inout FlatBufferBuilder, start: UOffset) -> Offset {
    let end = Offset(offset: fbb.endTable(at: start))
    return end
  }
  public static func createBenchDoc(
    _ fbb: inout FlatBufferBuilder,
    pos: zzz_DflatGen_Vec3? = nil,
    color: zzz_DflatGen_Color = .red,
    titleOffset title: Offset = Offset(),
    contentType: zzz_DflatGen_Content = .none_,
    contentOffset content: Offset = Offset(),
    tagOffset tag: Offset = Offset(),
    priority: Int32 = 0
  ) -> Offset {
    let __start = zzz_DflatGen_BenchDoc.startBenchDoc(&fbb)
    zzz_DflatGen_BenchDoc.add(pos: pos, &fbb)
    zzz_DflatGen_BenchDoc.add(color: color, &fbb)
    zzz_DflatGen_BenchDoc.add(title: title, &fbb)
    zzz_DflatGen_BenchDoc.add(contentType: contentType, &fbb)
    zzz_DflatGen_BenchDoc.add(content: content, &fbb)
    zzz_DflatGen_BenchDoc.add(tag: tag, &fbb)
    zzz_DflatGen_BenchDoc.add(priority: priority, &fbb)
    return zzz_DflatGen_BenchDoc.endBenchDoc(&fbb, start: __start)
  }

  public static func verify<T>(_ verifier: inout Verifier, at position: Int, of type: T.Type) throws
  where T: Verifiable {
    var _v = try verifier.visitTable(at: position)
    try _v.visit(
      field: VTOFFSET.pos.p, fieldName: "pos", required: false, type: zzz_DflatGen_Vec3.self)
    try _v.visit(
      field: VTOFFSET.color.p, fieldName: "color", required: false, type: zzz_DflatGen_Color.self)
    try _v.visit(
      field: VTOFFSET.title.p, fieldName: "title", required: false, type: ForwardOffset<String>.self
    )
    try _v.visit(
      unionKey: VTOFFSET.contentType.p, unionField: VTOFFSET.content.p, unionKeyName: "contentType",
      fieldName: "content", required: false,
      completion: { (verifier, key: zzz_DflatGen_Content, pos) in
        switch key {
        case .none_:
          break  // NOTE - SWIFT doesnt support none
        case .textcontent:
          try ForwardOffset<zzz_DflatGen_TextContent>.verify(
            &verifier, at: pos, of: zzz_DflatGen_TextContent.self)
        case .imagecontent:
          try ForwardOffset<zzz_DflatGen_ImageContent>.verify(
            &verifier, at: pos, of: zzz_DflatGen_ImageContent.self)
        }
      })
    try _v.visit(
      field: VTOFFSET.tag.p, fieldName: "tag", required: false, type: ForwardOffset<String>.self)
    try _v.visit(
      field: VTOFFSET.priority.p, fieldName: "priority", required: false, type: Int32.self)
    _v.finish()
  }
}
