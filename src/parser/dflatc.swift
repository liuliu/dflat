import Foundation

enum EnumTypeEnum: String, Decodable {
  case none = ""
  case `struct` = "struct"
}

struct EnumVal: Decodable {
  var name: String
  var type: EnumTypeEnum
  var `struct`: String?
  var value: Int
}

struct Enum: Decodable {
  var name: String
  var isUnion: Bool
  var namespace: [String]
  var underlyingType: String?
  var fields: [EnumVal]
}

enum ElementTypeEnum: String, Decodable {
  case none = ""
  case `struct` = "struct"
  case utype = "utype"
  case union = "union"
  case `enum` = "enum"
  case bool = "bool"
  case byte = "byte"
  case ubyte = "ubyte"
  case short = "short"
  case ushort = "ushort"
  case int = "int"
  case uint = "uint"
  case long = "long"
  case ulong = "ulong"
  case float = "float"
  case double = "double"
  case string = "string"
}

struct ElementType: Decodable {
  var type: ElementTypeEnum
  var `struct`: String?
  var utype: String?
  var union: String?
  var `enum`: String?
}

enum TypeEnum: String, Decodable {
  case none = ""
  case vector = "vector"
  case `struct` = "struct"
  case utype = "utype"
  case union = "union"
  case `enum` = "enum"
  case bool = "bool"
  case byte = "byte"
  case ubyte = "ubyte"
  case short = "short"
  case ushort = "ushort"
  case int = "int"
  case uint = "uint"
  case long = "long"
  case ulong = "ulong"
  case float = "float"
  case double = "double"
  case string = "string"
}

struct Type: Decodable {
  var type: TypeEnum
  var element: ElementType?
  var `struct`: String?
  var utype: String?
  var union: String?
  var `enum`: String?
}

struct Field: Decodable {
  var name: String
  var type: Type
  var `default`: String?
  var deprecated: Bool
  var attributes: [String]
}

struct Struct: Decodable {
  var name: String
  var fixed: Bool
  var namespace: [String]
  var fields: [Field]
}

struct Schema: Decodable {
  var enums: [Enum]
  var structs: [Struct]
  var root: String
}

var SwiftType: [String: String] = [
  "utype": "UInt8",
  "bool": "Bool",
  "byte": "Int8",
  "ubyte": "UInt8",
  "short": "Int16",
  "ushort": "UInt16",
  "int": "Int32",
  "uint": "UInt32",
  "long": "Int64",
  "ulong": "UInt64",
  "float": "Float32",
  "double": "Double",
  "string": "String?",
]

extension String {
  func firstLowercased() -> String {
    prefix(1).lowercased() + dropFirst()
  }
  func firstUppercased() -> String {
    prefix(1).uppercased() + dropFirst()
  }
}

extension Field {
  var isPrimary: Bool {
    attributes.contains("primary")
  }
}

extension Enum {
  func findEnumVal(_ value: Int) -> EnumVal? {
    for field in fields {
      if field.value == value {
        return field
      }
    }
    return nil
  }
}

var enumDefs = [String: Enum]()
var structDefs = [String: Struct]()

func SetNamespace(_ namespace: [String], previous pns: inout [String], code: inout String) {
  guard namespace != pns else { return }
  for ns in pns {
    code += "\n}\n\n// MARK: - \(ns)\n"
  }
  // This is actually not right. If we previously declared, we need to use extension Namespace1.Namespace2 instead.
  for ns in namespace {
    code += "\npublic enum \(ns) {\n"
  }
  pns = namespace
}

func GenEnumDataModel(_ enumDef: Enum, code: inout String) {
  code += "\npublic enum \(enumDef.name): \(SwiftType[enumDef.underlyingType!]!), DflatFriendlyValue {\n"
  for field in enumDef.fields {
    code += "  case \(field.name.firstLowercased()) = \(field.value)\n"
  }
  code += "  public static func < (lhs: \(enumDef.name), rhs: \(enumDef.name) -> Bool {\n"
  code += "    return lhs.rawValue < rhs.rawValue\n"
  code += "  }\n"
  code += "}\n"
}

func GenUnionDataModel(_ enumDef: Enum, code: inout String) {
  code += "\npublic enum \(enumDef.name): Equatable {\n"
  for field in enumDef.fields {
    guard field.name != "NONE" else { continue }
    code += "  case \(field.name.firstLowercased())(_: \(field.name))\n"
  }
  code += "}\n"
}

func GetElementType(_ type: ElementType) -> String {
  switch type.type {
  case .struct:
    return type.struct!
  case .utype:
    return ""
  case .union:
    return type.union!
  case .enum:
    return type.enum!
  default:
    return SwiftType[type.type.rawValue]!
  }
}

func IsScalarElementType(_ type: ElementType) -> Bool {
  switch type.type {
  case .struct:
    return false
  case .utype:
    return false
  case .union:
    return false
  case .enum:
    return false
  case .string:
    return false
  default:
    return true
  }
}

func GetFieldType(_ field: Field) -> String {
  var fieldType: String
  switch field.type.type {
  case .struct:
    fieldType = field.type.struct! + "?"
  case .vector:
    fieldType = "[\(GetElementType(field.type.element!))]"
  case .utype:
    fieldType = ""
  case .union:
    fieldType = field.type.union! + "?"
  case .enum:
    fieldType = field.type.enum!
  default:
    fieldType = SwiftType[field.type.type.rawValue]!
  }
  if field.isPrimary {
    if fieldType.suffix(1) == "?" {
      fieldType.removeLast()
    }
  }
  return fieldType
}

func GetFieldRequiredType(_ field: Field) -> String {
  var fieldType = GetFieldType(field)
  if fieldType.suffix(1) == "?" {
    fieldType.removeLast()
  }
  return fieldType
}

func IsDataField(_ field: Field) -> Bool {
  if field.deprecated {
    return false
  }
  if field.type.type == .utype {
    return false
  }
  if field.type.type == .vector && field.type.element!.type == .utype {
    return false
  }
  return true
}

func GetFullyQualifiedName(_ structDef: Struct) -> String {
  if structDef.namespace.count > 0 {
    return structDef.namespace.joined(separator: ".") + ".\(structDef.name)"
  } else {
    return structDef.name
  }
}

func GetFullyQualifiedName(_ enumDef: Enum) -> String {
  if enumDef.namespace.count > 0 {
    return enumDef.namespace.joined(separator: ".") + ".\(enumDef.name)"
  } else {
    return enumDef.name
  }
}

func GetEnumDefaultValue(_ en: String) -> String {
    let enumDef = enumDefs[en]!
    let enumVal = enumDef.findEnumVal(0) ?? enumDef.fields.first!
    return ".\(enumVal.name.firstLowercased())"
}

func GetFieldDefaultValue(_ field: Field) -> String {
  if let val = field.default {
    if field.type.type == .enum {
      let enumDef = enumDefs[field.type.enum!]!
      let enumVal = enumDef.findEnumVal(Int(val)!)!
      return ".\(enumVal.name.firstLowercased())"
    }
    return val
  }
  if field.isPrimary && field.type.type == .string {
    return "\"\""
  }
  if field.type.type == .string || field.type.type == .struct ||
     field.type.type == .utype || field.type.type == .union {
    return "nil"
  }
  if field.type.type == .enum {
    return GetEnumDefaultValue(field.type.enum!)
  }
  if field.type.type == .vector {
    return "[]"
  }
  return "0"
}

func GetStructInit(_ structDef: Struct) -> String {
  var parameters = [String]()
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    guard field.isPrimary else { continue }
    parameters.append("\(field.name): \(GetFieldType(field))")
  }
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    guard !field.isPrimary else { continue }
    parameters.append("\(field.name): \(GetFieldType(field)) = \(GetFieldDefaultValue(field))")
  }
  return parameters.joined(separator: ", ")
}

func GetStructDeserializer(_ structDef: Struct) -> String {
  var code = ""
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    switch field.type.type {
    case .struct:
      code += "    self.\(field.name) = obj.\(field.name).map { \(GetFieldRequiredType(field))($0) }\n"
    case .vector:
      if IsScalarElementType(field.type.element!) {
        code += "    self.\(field.name) = obj.\(field.name)\n"
      } else {
        code += "    var __\(field.name) = \(GetFieldType(field))()\n"
        code += "    for i: Int32 in 0..<obj.\(field.name)Count {\n"
        switch field.type.element!.type {
          case .struct:
            code += "      guard let o = obj.\(field.name)(at: i) else { break }\n"
            code += "      __\(field.name).append(\(GetElementType(field.type.element!))(o))\n"
          case .union:
            code += "      guard let ot = obj.\(field.name)Type(at: i) else { break }\n"
            code += "      switch ot {\n"
            code += "      case .none_:\n"
            code += "        fatalError()\n"
            let enumDef = enumDefs[field.type.element!.union!]!
            for enumVal in enumDef.fields {
              guard enumVal.name != "NONE" else { continue }
              code += "      case .\(enumVal.name.firstLowercased()):\n"
              let subStructDef = structDefs[enumVal.struct!]!
              code += "        __\(field.name).append(obj.\(field.name)(at: i, type: FlatBuffers_Generated.\(GetFullyQualifiedName(subStructDef)).self).map { .\(enumVal.name.firstLowercased())(\(enumVal.name)($0)) }\n"
            }
          case .enum:
            code += "      guard let o = obj.\(field.name)(at: i) else { break }\n"
            code += "      __\(field.name).append(\(GetElementType(field.type.element!))(rawValue: o.rawValue) ?? \(GetEnumDefaultValue(field.type.element!.enum!)))\n"
          default:
            fatalError(field.type.element!.type.rawValue)
        }
        code += "    }\n"
        code += "    self.\(field.name) = __\(field.name)\n"
      }
    case .union:
      code += "    switch obj.\(field.name)Type {\n"
      code += "    case .none_:\n"
      code += "      self.\(field.name) = nil\n"
      let enumDef = enumDefs[field.type.union!]!
      for enumVal in enumDef.fields {
        guard enumVal.name != "NONE" else { continue }
        code += "    case .\(enumVal.name.firstLowercased()):\n"
        let subStructDef = structDefs[enumVal.struct!]!
        code += "      self.\(field.name) = obj.\(field.name)(type: FlatBuffers_Generated.\(GetFullyQualifiedName(subStructDef)).self).map { .\(enumVal.name.firstLowercased())(\(enumVal.name)($0)) }\n"
      }
      code += "    }\n"
    case .enum:
      code += "    self.\(field.name) = \(GetFieldType(field))(rawValue: obj.\(field.name).rawValue) ?? \(GetFieldDefaultValue(field))\n"
    default:
      code += "    self.\(field.name) = obj.\(field.name)\n"
    }
  }
  return code
}

func GenStructDataModel(_ structDef: Struct, code: inout String) {
  code += "\npublic struct \(structDef.name): Equatable {\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "  var \(field.name): \(GetFieldType(field))\n"
  }
  code += "  public init(\(GetStructInit(structDef))) {\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "    self.\(field.name) = \(field.name)\n"
  }
  code += "  }\n"
  code += "  public init(_ obj: FlatBuffers_Generated.\(GetFullyQualifiedName(structDef))) {\n"
  code += GetStructDeserializer(structDef)
  code += "  }\n"
  code += "}\n"
}

func GenRootDataModel(_ structDef: Struct, code: inout String) {
  code += "\npublic final class \(structDef.name): Dflat.Atom, Equatable {\n"
  code += "  public static func == (lhs: \(structDef.name), rhs: \(structDef.name)) -> Bool {\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "    guard lhs.\(field.name) == rhs.\(field.name) else { return false }\n"
  }
  code += "    return true\n"
  code += "  }\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "  let \(field.name): \(GetFieldType(field))\n"
  }
  code += "  public init(\(GetStructInit(structDef))) {\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "    self.\(field.name) = \(field.name)\n"
  }
  code += "  }\n"
  code += "  public init(_ obj: FlatBuffers_Generated.\(GetFullyQualifiedName(structDef))) {\n"
  code += GetStructDeserializer(structDef)
  code += "  }\n"
  code += "  override public class func fromFlatBuffers(_ bb: ByteBuffer) -> Self {\n"
  code += "    Self(FlatBuffers_Generated.\(GetFullyQualifiedName(structDef)).getRootAs\(structDef.name)(bb: bb))\n"
  code += "  }\n"
  code += "}\n"
}

func GenDataModel(schema: Schema, outputPath: String) {
  var code = "import Dflat\nimport FlatBuffers\n"
  var namespace: [String] = []
  for enumDef in schema.enums {
    SetNamespace(enumDef.namespace, previous: &namespace, code: &code)
    if enumDef.isUnion {
      GenUnionDataModel(enumDef, code: &code)
    } else {
      GenEnumDataModel(enumDef, code: &code)
    }
  }
  for structDef in schema.structs {
    if structDef.name != schema.root {
      SetNamespace(structDef.namespace, previous: &namespace, code: &code)
      GenStructDataModel(structDef, code: &code)
    }
  }
  for structDef in schema.structs {
    if structDef.name == schema.root {
      SetNamespace(structDef.namespace, previous: &namespace, code: &code)
      GenRootDataModel(structDef, code: &code)
      break
    }
  }
  SetNamespace([String](), previous: &namespace, code: &code)
}

func GenEnumSQLiteValue(_ enumDef: Enum, code: inout String) {
  code += "\nextension \(GetFullyQualifiedName(enumDef)): SQLiteValue {\n"
  code += "  public func bindSQLite(_ query: OpaquePointer, parameterId: Int32) {\n"
  code += "    self.rawValue.bindSQLite(query, parameterId: parameterId)\n"
  code += "  }\n"
  code += "}\n"
}

func GenUnionSerializer(_ enumDef: Enum, code: inout String) {
  code += "\nextension \(GetFullyQualifiedName(enumDef)) {\n"
  code += "  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {\n"
  code += "    switch self {\n"
  for enumVal in enumDef.fields {
    guard enumVal.name != "NONE" else { continue }
    code += "    case .\(enumVal.name.firstLowercased())(let o):\n"
    code += "      return o.to(flatBufferBuilder: &flatBufferBuilder)\n"
  }
  code += "    }\n"
  code += "  }\n"
  code += "  var _type: FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef)) {\n"
  code += "    switch self {\n"
  for enumVal in enumDef.fields {
    guard enumVal.name != "NONE" else { continue }
    code += "    case .\(enumVal.name.firstLowercased())(_):\n"
    code += "      return FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef)).\(enumVal.name.firstLowercased())\n"
  }
  code += "    }\n"
  code += "  }\n"
  code += "}\n"
  code += "\nextension Optional where Wrapped == \(GetFullyQualifiedName(enumDef)) {\n"
  code += "  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {\n"
  code += "    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()\n"
  code += "  }\n"
  code += "  var _type: FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef)) {\n"
  code += "    self.map { $0._type } ?? .none_\n"
  code += "  }\n"
  code += "}\n"
}

func GenStructSerializer(_ structDef: Struct, code: inout String) {
  code += "\nextension \(GetFullyQualifiedName(structDef)) {\n"
  if structDef.fixed {
    code += "  func toRawMemory() -> UnsafeMutableRawPointer {\n"
  } else {
    code += "  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {\n"
  }
  var parameters = [String]()
  for field in structDef.fields {
    switch field.type.type {
    case .struct:
      let subStructDef = structDefs[field.type.struct!]!
      if subStructDef.fixed {
        code += "    let __\(field.name) = \(field.name).toRawMemory()\n"
        parameters.append("structOf\(field.name.firstUppercased()): __\(field.name)")
        break
      }
      fallthrough
    case .union:
      code += "    let __\(field.name) = \(field.name).to(flatBufferBuilder: &flatBufferBuilder)\n"
      parameters.append("offsetOf\(field.name.firstUppercased()): __\(field.name)")
    case .vector:
      if IsScalarElementType(field.type.element!) {
        code += "    let __\(field.name) = flatBufferBuilder.createVector(\(field.name))\n"
        parameters.append("vectorOf\(field.name.firstUppercased()): __\(field.name)")
      } else {
        switch field.type.element!.type {
        case .struct:
          let subStructDef = structDefs[field.type.element!.struct!]!
          if subStructDef.fixed {
            code += "    var __\(field.name) = [UnsafeMutableRawPointer]()\n"
            code += "    for i in \(field.name) {\n"
            code += "      __\(field.name).append(i.toRawMemory())\n"
            code += "    }\n"
            code += "    let __vector_\(field.name) = flatBufferBuilder.createVector(structs: __\(field.name), type: FlatBuffers_Generated.\(GetFullyQualifiedName(subStructDef)).self)\n"
            parameters.append("vectorOf\(field.name.firstUppercased()): __vector_\(field.name)")
            break
          }
          fallthrough
        case .union:
          code += "    var __\(field.name) = [Offset<UOffset>]()\n"
          code += "    for i in \(field.name) {\n"
          code += "      __\(field.name).append(i.to(flatBufferBuilder: &flatBufferBuilder))\n"
          code += "    }\n"
          parameters.append("vectorOf\(field.name.firstUppercased()): __\(field.name)")
        case .utype:
          let enumDef = enumDefs[field.type.element!.utype!]!
          let fieldName = field.name.prefix(field.name.count - 5) + "Type"
          code += "    var __\(fieldName) = [FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef))]()\n"
          code += "    for i in \(field.name.prefix(field.name.count - 5)) {\n"
          code += "      __\(fieldName).append(i._type)\n"
          code += "    }\n"
          code += "    let __vector_\(fieldName) = flatBufferBuilder.createVector(__\(fieldName))\n"
          parameters.append("vectorOf\(fieldName.prefix(1).uppercased() + fieldName.dropFirst()): __vector_\(fieldName)")
        case .string:
          code += "    var __\(field.name) = [Offset<UOffset>]()\n"
          code += "    for i in \(field.name) {\n"
          code += "      __\(field.name).append(flatBufferBuilder.create(string: i))\n"
          code += "    }\n"
          parameters.append("vectorOf\(field.name.firstUppercased()): __\(field.name)")
        case .enum:
          let enumDef = enumDefs[field.type.element!.enum!]!
          code += "    var __\(field.name) = [FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef))]()\n"
          code += "    for i in \(field.name) {\n"
          code += "      __\(field.name).append(FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef))(rawValue: i.rawValue) ?? \(GetEnumDefaultValue(field.type.element!.enum!)))\n"
          code += "    }\n"
          code += "    let __vector_\(field.name) = flatBufferBuilder.createVector(__\(field.name))\n"
          parameters.append("vectorOf\(field.name.firstUppercased()): __vector_\(field.name)")
        default:
          break
        }
      }
    case .utype:
      let fieldName = field.name.prefix(field.name.count - 5) + "Type"
      code += "    let __\(fieldName) = \(field.name.prefix(field.name.count - 5))._type\n"
      parameters.append("\(fieldName): __\(fieldName)")
    case .enum:
      let enumDef = enumDefs[field.type.enum!]!
      code += "    let __\(field.name) = FlatBuffers_Generated.\(GetFullyQualifiedName(enumDef))(rawValue: \(field.name).rawValue) ?? \(GetFieldDefaultValue(field))\n"
      parameters.append("\(field.name): __\(field.name)")
    case .string:
      code += "    let __\(field.name) = \(field.name).map { flatBufferBuilder.create(string: $0) } ?? Offset<String>()\n"
      parameters.append("offsetOf\(field.name.firstUppercased()): __\(field.name)")
    default:
      parameters.append("\(field.name): \(field.name)")
    }
  }
  if structDef.fixed {
    code += "    return FlatBuffers_Generated.\(structDef.namespace.joined(separator: ".")).create\(structDef.name)(\(parameters.joined(separator: ", ")))\n"
  } else {
    code += "    return FlatBuffers_Generated.\(GetFullyQualifiedName(structDef)).create\(structDef.name)(\(parameters.joined(separator: ", ")))\n"
  }
  code += "  }\n"
  code += "}\n"
  code += "\nextension Optional where Wrapped == \(GetFullyQualifiedName(structDef)) {\n"
  if structDef.fixed {
    code += "  func toRawMemory() -> UnsafeMutableRawPointer? {\n"
    code += "    self.map { $0.toRawMemory() }\n"
  } else {
    code += "  func to(flatBufferBuilder: inout FlatBufferBuilder) -> Offset<UOffset> {\n"
    code += "    self.map { $0.to(flatBufferBuilder: &flatBufferBuilder) } ?? Offset()\n"
  }
  code += "  }\n"
  code += "}\n"
}

func GenChangeRequest(_ structDef: Struct, code: inout String) {
  if structDef.namespace.count > 0 {
    code += "extension \(structDef.namespace.joined(separator: ".")) {\n"
  }
  code += "\npublic final class \(structDef.name)ChangeRequest: Dflat.ChangeRequest {\n"
  code += "  public static var atomType: Any.Type { \(structDef.name).self }\n"
  code += "  public var _type: ChangeRequestType\n"
  code += "  public var _rowid: Int64\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "  public var \(field.name): \(GetFieldType(field))\n"
  }
  code += "  public init(type: ChangeRequestType) {\n"
  code += "    _type = type\n"
  code += "    _rowid = rowid\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "    \(field.name) = \(GetFieldDefaultValue(field))\n"
  }
  code += "  }\n"
  code += "  public init(type: ChangeRequestType, _ o: \(structDef.name)) {\n"
  code += "    _type = type\n"
  code += "    _rowid = o._rowid\n"
  for field in structDef.fields {
    guard IsDataField(field) else { continue }
    code += "    \(field.name) = o.\(field.name)\n"
  }
  code += "  }\n"
  if structDef.namespace.count > 0 {
    code += "}\n"
    code += "\n// MARK - \(structDef.namespace.joined(separator: "."))\n"
  }
}

func GenMutating(schema: Schema, outputPath: String) {
  var code = "import Dflat\nimport SQLiteDflat\nimport SQLite3\nimport FlatBuffers\n\n"
  code += "// MARK - SQLiteValue for Enumerations\n"
  for enumDef in schema.enums {
    guard !enumDef.isUnion else { continue }
    GenEnumSQLiteValue(enumDef, code: &code)
  }
  code += "\n// MARK - Serializer\n"
  for enumDef in schema.enums {
    guard enumDef.isUnion else { continue }
    GenUnionSerializer(enumDef, code: &code)
  }
  for structDef in schema.structs {
    guard structDef.name != schema.root else { continue }
    GenStructSerializer(structDef, code: &code)
  }
  for structDef in schema.structs {
    guard !structDef.fixed else { continue }
    if structDef.name == schema.root {
      GenStructSerializer(structDef, code: &code)
    }
  }
  code += "\n// MARK - ChangeRequest\n"
  for structDef in schema.structs {
    guard !structDef.fixed else { continue }
    if structDef.name == schema.root {
      GenChangeRequest(structDef, code: &code)
    }
  }
  print(code)
}

func GenSwift(_ filePath: String, _ outputPath: String) {
  let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  let schema = try! decoder.decode(Schema.self, from: data)
  for enumDef in schema.enums {
    enumDefs[enumDef.name] = enumDef
  }
  for structDef in schema.structs {
    structDefs[structDef.name] = structDef
  }
  GenDataModel(schema: schema, outputPath: outputPath)
  GenMutating(schema: schema, outputPath: outputPath)
}

var outputPath: String? = nil
var argi = 1
var filePaths = [String]()
while argi < CommandLine.arguments.count {
  let argument = CommandLine.arguments[argi]
  if argument == "-o" {
    argi += 1
    if argi >= CommandLine.arguments.count {
      fatalError("missing path following -o")
    }
    outputPath = CommandLine.arguments[argi]
  } else {
    filePaths.append(argument)
  }
  argi += 1
}
guard let outputPath = outputPath else { fatalError("no output path specified") }
for filePath in filePaths {
  GenSwift(filePath, outputPath)
}
