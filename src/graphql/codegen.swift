import ChangeCases
import CommonCrypto
import Foundation
import InflectorKit

@testable import ApolloCodegenLib

extension String {
  func digest() -> String {
    guard let input = self.data(using: .utf8) else {
      return ""
    }
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    let bytes = input.withUnsafeBytes { input -> [UInt8] in
      guard let baseAddress = input.baseAddress else { return [] }
      var bytes = [UInt8](repeating: 0, count: digestLength)
      CC_SHA256(baseAddress, UInt32(input.count), &bytes)
      return bytes
    }
    var hexString = ""
    for byte in bytes {
      hexString += String(format: "%02x", UInt8(byte))
    }
    return hexString
  }
}

let bundle = Bundle(for: ApolloCodegenFrontend.self)
if let resourceUrl = bundle.resourceURL,
  let bazelResourceJsUrl = bundle.url(
    forResource: "ApolloCodegenFrontend.bundle", withExtension: "js",
    subdirectory: "codegen.runfiles/apollo-ios/Sources/ApolloCodegenLib/Frontend/dist")
{
  let standardDistUrl = resourceUrl.appendingPathComponent("dist")
  try? FileManager.default.createDirectory(at: standardDistUrl, withIntermediateDirectories: true)
  let standardJsUrl = standardDistUrl.appendingPathComponent("ApolloCodegenFrontend.bundle.js")
  try? FileManager.default.linkItem(at: bazelResourceJsUrl, to: standardJsUrl)
}

let codegenFrontend = try ApolloCodegenFrontend()

var FlatBuffersFromSwiftType: [String: String] = [
  "Bool": "bool",
  "Int8": "byte",
  "UInt8": "ubyte",
  "Int16": "short",
  "UInt16": "ushort",
  "Int32": "int",
  "UInt32": "uint",
  "Int64": "long",
  "UInt64": "ulong",
  "Float32": "float",
  "Double": "double",
  "String" : "string",
]

let schemaPath = CommandLine.arguments[1]
var documentPaths = [String]()
var entities = [String]()
var outputDir: String? = nil
var primaryKey: String = ""
var primaryKeyType: String = "String"
enum CommandOptions {
  case document
  case entity
  case output
  case primaryKey
  case primaryKeyType
}
var options = CommandOptions.document
for argument in CommandLine.arguments[2...] {
  if argument == "--entity" {
    options = .entity
  } else if argument == "-o" {
    options = .output
  } else if argument == "--primary-key" {
    options = .primaryKey
  } else if argument == "--primary-key-type" {
    options = .primaryKeyType
  } else {
    switch options {
    case .document:
      documentPaths.append(argument)
    case .entity:
      entities.append(argument)
    case .output:
      outputDir = argument
    case .primaryKey:
      primaryKey = argument
    case .primaryKeyType:
      primaryKeyType = argument
      precondition(FlatBuffersFromSwiftType[primaryKeyType] != nil)
    }
  }
}

let schema = try codegenFrontend.loadSchema(from: URL(fileURLWithPath: schemaPath))

var documents = [GraphQLDocument]()
for documentPath in documentPaths {
  let document = try codegenFrontend.parseDocument(from: URL(fileURLWithPath: documentPath))
  documents.append(document)
}

let document = try codegenFrontend.mergeDocuments(documents)

let validationErrors = try codegenFrontend.validateDocument(schema: schema, document: document)
guard validationErrors.isEmpty else {
  print(validationErrors)
  exit(-1)
}

// Record available fields from the queries. This will help to cull any fields that exists in the schema but not
// used anywhere in the query.

func findObjectFields(
  objectFields: inout [String: Set<String>], entities: Set<String>,
  selectionSet: CompilationResult.SelectionSet, marked: Bool
) {
  let typeName = selectionSet.parentType.name
  let marked = marked || entities.contains(typeName)
  for selection in selectionSet.selections {
    switch selection {
    case let .field(field):
      if marked {
        objectFields[typeName, default: Set<String>()].insert(field.name)
      }
      if let selectionSet = field.selectionSet {
        findObjectFields(
          objectFields: &objectFields, entities: entities, selectionSet: selectionSet,
          marked: marked)
      }
    case let .inlineFragment(inlineFragment):
      findObjectFields(
        objectFields: &objectFields, entities: entities, selectionSet: inlineFragment.selectionSet,
        marked: marked)
    case let .fragmentSpread(fragmentSpread):
      findObjectFields(
        objectFields: &objectFields, entities: entities,
        selectionSet: fragmentSpread.fragment.selectionSet, marked: marked)
      break
    }
  }
}

var objectFields = [String: Set<String>]()
let compilationResult = try codegenFrontend.compile(schema: schema, document: document)
for operation in compilationResult.operations {
  findObjectFields(
    objectFields: &objectFields, entities: Set(entities), selectionSet: operation.selectionSet,
    marked: false)
}

func flatbuffersType(_ graphQLType: GraphQLType, rootType: GraphQLNamedType) -> String {
  let scalarTypes: [String: String] = [
    "Int": "int", "Float": "double", "Boolean": "bool", "ID": "string", "String": "string",
  ]
  switch graphQLType {
  case .named(let namedType):
    if namedType == rootType {
      return "string"
    } else {
      return scalarTypes[namedType.name] ?? namedType.name
    }
  case .nonNull(let graphQLType):
    return flatbuffersType(graphQLType, rootType: rootType)
  case .list(let itemType):
    return "[\(flatbuffersType(itemType, rootType: rootType))]"
  }
}

func digestType(
  _ graphQLType: GraphQLType, rootType: GraphQLNamedType, typeDigests: [String: String]
) -> String {
  switch graphQLType {
  case .named(let namedType):
    if namedType == rootType {
      return "string"
    } else if isBaseType(graphQLType) {
      return namedType.name
    } else {
      return typeDigests[namedType.name]!
    }
  case .nonNull(let graphQLType):
    return digestType(graphQLType, rootType: rootType, typeDigests: typeDigests)
  case .list(let itemType):
    return "[\(digestType(itemType, rootType: rootType, typeDigests: typeDigests))]"
  }
}

// First, generate the flatbuffers schema file. One file per entity.

func generateEnumType(_ enumType: GraphQLEnumType) -> String {
  var fbs = ""
  fbs += "enum \(enumType.name): int {\n"
  let values = enumType.values
  for value in values {
    fbs += "  \(value.name.lowercased()),\n"
  }
  fbs += "}\n"
  return fbs
}

func generateEnumDigest(_ enumType: GraphQLEnumType) -> String {
  return enumType.values.map { $0.name.lowercased() }.joined(separator: ",").digest()
}

func generateObjectType(
  _ objectType: GraphQLObjectType, rootType: GraphQLNamedType, v: String? = nil
) -> String {
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  var fbs = ""
  let isRoot = rootType == objectType
  if let v = v {
    fbs += "table \(objectType.name) (v: \"\(v)\") {\n"
  } else {
    fbs += "table \(objectType.name) {\n"
  }
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  var emitPrimaryKey = false
  var restOfFields = ""
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name != primaryKey else {
      emitPrimaryKey = true
      if isRoot {
        restOfFields += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
      }
      continue
    }
    restOfFields += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
  }
  if !emitPrimaryKey && primaryKey.count > 0 && isRoot {
    fbs += "  \(primaryKey): \(FlatBuffersFromSwiftType[primaryKeyType]!) (primary);\n"
  }
  fbs += restOfFields
  fbs += "}\n"
  return fbs
}

func generateObjectDigest(
  _ objectType: GraphQLObjectType, rootType: GraphQLNamedType, typeDigests: [String: String]
) -> String {
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  let isRoot = rootType == objectType
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  var emitPrimaryKey = false
  var raw = [String]()
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name != primaryKey else {
      emitPrimaryKey = true
      if isRoot {
        raw.append("\(field.name):\(field.type)")
      }
      continue
    }
    raw.append(
      "\(field.name):\(digestType(field.type, rootType: rootType, typeDigests: typeDigests))")
  }
  if !emitPrimaryKey && primaryKey.count > 0 && isRoot {
    raw.insert("\(primaryKey):\(FlatBuffersFromSwiftType[primaryKeyType]!)", at: 0)
  }
  return raw.joined(separator: ",").digest()
}

func generateInterfaceType(
  _ interfaceType: GraphQLInterfaceType, rootType: GraphQLNamedType, v: String? = nil
)
  -> String
{
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  // For interfaces with multiple implementations, we first have all fields in the interface into the flatbuffers
  // and then having a union type that encapsulated into InterfaceSubtype and can be accessed through subtype field.
  var fbs = ""
  let isRoot = rootType == interfaceType
  if implementations.objects.count > 0 {
    fbs += isRoot ? "union Subtype {\n" : "union \(interfaceType.name)Subtype {\n"
    for object in implementations.objects {
      fbs += "  \(object.name),\n"
    }
    fbs += "}\n"
  }
  if isRoot {
    // Remove the extra namespace.
    fbs += "namespace;\n"
  }
  if let v = v {
    fbs += "table \(interfaceType.name) (v: \"\(v)\") {\n"
  } else {
    fbs += "table \(interfaceType.name) {\n"
  }
  let fields = interfaceType.fields.values.sorted(by: { $0.name < $1.name })
  let existingFields = objectFields[interfaceType.name]!
  var emitPrimaryKey = false
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name == primaryKey else { continue }
    emitPrimaryKey = true
    if isRoot {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
    } else {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
    }
  }
  if !emitPrimaryKey && primaryKey.count > 0 {
    if isRoot {
      fbs += "  \(primaryKey): \(FlatBuffersFromSwiftType[primaryKeyType]!) (primary);\n"
    } else {
      fbs += "  \(primaryKey): \(FlatBuffersFromSwiftType[primaryKeyType]!);\n"
    }
  }
  if implementations.objects.count > 0 {
    fbs +=
      isRoot
      ? "  subtype: \(interfaceType.name).Subtype;\n" : "  subtype: \(interfaceType.name)Subtype;\n"
  }
  fbs += "}\n"
  return fbs
}

func generateInterfaceDigest(
  _ interfaceType: GraphQLInterfaceType, rootType: GraphQLNamedType, typeDigests: [String: String]
) -> String {
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  var raw = ""
  if implementations.objects.count > 0 {
    raw +=
      "{" + implementations.objects.map({ typeDigests[$0.name]! }).joined(separator: ",") + "},"
  }
  let fields = interfaceType.fields.values.sorted(by: { $0.name < $1.name })
  let existingFields = objectFields[interfaceType.name]!
  var emitPrimaryKey = false
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name == primaryKey else { continue }
    emitPrimaryKey = true
    raw += "{\(field.name):\(flatbuffersType(field.type, rootType: rootType))}"
  }
  if !emitPrimaryKey && primaryKey.count > 0 {
      raw += "{\(primaryKey): \(FlatBuffersFromSwiftType[primaryKeyType]!)}"
  }
  return raw.digest()
}

func namedType(_ graphQLType: GraphQLType) -> GraphQLNamedType {
  switch graphQLType {
  case .named(let namedType):
    return namedType
  case .nonNull(let graphQLType):
    return namedType(graphQLType)
  case .list(let itemType):
    return namedType(itemType)
  }
}

func referencedTypes(
  rootType: GraphQLNamedType, set: inout Set<String>, _ array: inout [GraphQLNamedType]
) {
  if let interfaceType = rootType as? GraphQLInterfaceType {
    let implementations = try! schema.getImplementations(interfaceType: interfaceType)
    for objectType in implementations.objects {
      array.append(objectType)
      guard !set.contains(objectType.name) else { continue }
      set.insert(objectType.name)
      referencedTypes(rootType: objectType, set: &set, &array)
    }
  } else if let objectType = rootType as? GraphQLObjectType {
    let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
    var existingFields = objectFields[objectType.name]!
    for interfaceType in objectType.interfaces {
      existingFields.formUnion(objectFields[interfaceType.name]!)
    }
    for field in fields {
      guard existingFields.contains(field.name) else { continue }
      let fieldType = namedType(field.type)
      guard fieldType is GraphQLInterfaceType || fieldType is GraphQLObjectType else {
        if fieldType is GraphQLEnumType {
          set.insert(fieldType.name)
          array.append(fieldType)
        }
        continue
      }
      array.append(fieldType)
      guard !set.contains(fieldType.name) else { continue }
      set.insert(fieldType.name)
      referencedTypes(rootType: fieldType, set: &set, &array)
    }
  }
}

func generateFlatbuffers(_ rootType: GraphQLNamedType) -> String {
  var array = [GraphQLNamedType]()
  var set = Set<String>()
  set.insert(rootType.name)
  referencedTypes(rootType: rootType, set: &set, &array)
  set.removeAll()
  set.insert(rootType.name)
  var fbs = "namespace \(rootType.name);\n"
  var typeDigests = [String: String]()
  for entityType in array.reversed() {
    guard !set.contains(entityType.name) else { continue }
    set.insert(entityType.name)
    if let interfaceType = entityType as? GraphQLInterfaceType {
      typeDigests[entityType.name] = generateInterfaceDigest(
        interfaceType, rootType: rootType, typeDigests: typeDigests)
      fbs += generateInterfaceType(interfaceType, rootType: rootType)
    } else if let objectType = entityType as? GraphQLObjectType {
      typeDigests[entityType.name] = generateObjectDigest(
        objectType, rootType: rootType, typeDigests: typeDigests)
      fbs += generateObjectType(objectType, rootType: rootType)
    } else if let enumType = entityType as? GraphQLEnumType {
      typeDigests[entityType.name] = generateEnumDigest(enumType)
      fbs += generateEnumType(enumType)
    }
  }
  if let interfaceType = rootType as? GraphQLInterfaceType {
    let v = String(
      generateInterfaceDigest(interfaceType, rootType: rootType, typeDigests: typeDigests).prefix(
        16))
    fbs += generateInterfaceType(interfaceType, rootType: rootType, v: v)
  } else if let objectType = rootType as? GraphQLObjectType {
    let v = String(
      generateObjectDigest(objectType, rootType: rootType, typeDigests: typeDigests).prefix(16))
    fbs += generateObjectType(objectType, rootType: rootType, v: v)
  } else {
    fatalError("Cannot generate flatbuffers schema for root enum type")
  }
  // If we have primary key, this can be a root type, otherwise this cannot be one.
  if primaryKey.count > 0 {
    fbs += "root_type \(rootType.name);\n"
  }
  return fbs
}

func isBaseType(_ graphQLType: GraphQLType) -> Bool {
  switch graphQLType {
  case .named(let type):
    return ["Int", "Float", "String", "Boolean", "ID"].contains(type.name)
  case .nonNull(let ofType):
    return isBaseType(ofType)
  case .list(_):
    return false
  }
}

func isIDType(_ graphQLType: GraphQLType) -> Bool {
  switch graphQLType {
  case .named(let type):
    return ["ID"].contains(type.name)
  case .nonNull(let ofType):
    return isIDType(ofType)
  case .list(_):
    return false
  }
}

enum FieldKeyPosition: Equatable {
  case noKey
  case inField
  case inInlineFragment(String)
  case inFragmentSpread(String, Bool)
}

func isOptionalFragments(fragmentType: GraphQLCompositeType, objectType: GraphQLCompositeType)
  -> Bool
{
  // If the object type is interface while fragment is not, that means we may have empty object for
  // a given interface, hence, this fragment can be optional.
  return !(fragmentType is GraphQLInterfaceType) && (objectType is GraphQLInterfaceType)
}

func primaryKeyPosition(objectType: GraphQLCompositeType, selections: [CompilationResult.Selection])
  -> FieldKeyPosition
{
  for selection in selections {
    switch selection {
    case let .field(field):
      if field.name == primaryKey && isIDType(field.type) {
        return .inField
      }
    case .inlineFragment(_), .fragmentSpread(_):
      break
    }
  }
  for selection in selections {
    switch selection {
    case .field(_), .inlineFragment(_):
      break
    case let .fragmentSpread(fragmentSpread):
      let fragmentType = fragmentSpread.fragment.selectionSet.parentType
      for selection in fragmentSpread.fragment.selectionSet.selections {
        if case let .field(field) = selection {
          if field.name == primaryKey && isIDType(field.type) {
            return .inFragmentSpread(
              fragmentSpread.fragment.name.pascalCase(),
              isOptionalFragments(fragmentType: fragmentType, objectType: objectType))
          }
        }
      }
    }
  }
  return .noKey
}

func generateInterfaceInits(
  _ interfaceType: GraphQLInterfaceType,
  rootType: GraphQLNamedType, fullyQualifiedName: [String],
  selections: [CompilationResult.Selection]
) -> String {
  let isRoot = rootType == interfaceType
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(interfaceType.name) {\n" : "extension \(interfaceType.name) {\n"
  let keyPosition = primaryKeyPosition(objectType: interfaceType, selections: selections)
  let noKey: Bool
  switch keyPosition {
  case .noKey, .inInlineFragment(_):
    noKey = true
  default:
    noKey = false
  }
  if primaryKey.count > 0 && noKey {
    if isRoot {
      inits += "  public convenience init(\(primaryKey): \(primaryKeyType), _ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    } else {
      inits += "  public init(\(primaryKey): \(primaryKeyType), _ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    }
  } else {
    if isRoot {
      inits += "  public convenience init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    } else {
      inits += "  public init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    }
  }
  let subtype =
    isRoot ? "\(rootType.name).Subtype" : "\(rootType.name).\(interfaceType.name)Subtype"
  switch keyPosition {
  case .inField:
    inits +=
      "    self.init(\(primaryKey): obj.\(primaryKey.camelCase()), subtype: \(subtype)(obj))\n"
  case let .inFragmentSpread(name, _):
    inits +=
      "    self.init(\(primaryKey): obj.fragments.\(name.camelCase()).\(primaryKey.camelCase()), subtype: \(subtype)(obj))\n"
  case .noKey, .inInlineFragment(_):
    if primaryKey.count > 0 {
      inits +=
        "    self.init(\(primaryKey): \(primaryKey), subtype: \(subtype)(obj))\n"
    } else {
      inits +=
        "    self.init(subtype: \(subtype)(obj))\n"
    }
  }
  inits += "  }\n"
  inits += "}\n"
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  guard implementations.objects.count > 0 else { return inits }
  inits +=
    !isRoot
    ? "extension \(rootType.name).\(interfaceType.name)Subtype {\n"
    : "extension \(interfaceType.name).Subtype {\n"
  inits += "  public init?(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
  inits += "    switch obj.__typename {\n"
  for object in implementations.objects {
    inits += "    case \"\(object.name)\":\n"
    inits += "      self = .\(object.name.firstLowercased())(.init(obj))\n"
  }
  inits += "    default:\n"
  inits += "      return nil\n"
  inits += "    }\n"
  inits += "  }\n"
  inits += "}\n"
  return inits
}

func getImplementations(from namedType: GraphQLNamedType) -> [GraphQLObjectType] {
  guard let interfaceType = namedType as? GraphQLInterfaceType else {
    return []
  }
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  return implementations.objects
}

func unwrapType(prefix: String, inner: String, type: GraphQLType, optional: Bool) -> String {
  switch type {
  case .named(_):
    return inner == "" ? prefix : "\(prefix).flatMap { \(inner) }"
  case .nonNull(let nonNullType):
    if case .list(_) = nonNullType {
      return unwrapType(prefix: prefix, inner: inner, type: nonNullType, optional: false)
    } else {
      return inner == "" ? prefix : "\(prefix).map { \(inner) }"
    }
  case .list(let listType):
    if optional {
      return
        "\(prefix)?.compactMap { \(unwrapType(prefix: "$0", inner: inner, type: listType, optional: false)) } ?? []"
    } else {
      return
        "\(prefix).compactMap { \(unwrapType(prefix: "$0", inner: inner, type: listType, optional: false)) }"
    }
  }
}

func generateObjectInits(
  _ objectType: GraphQLObjectType,
  rootType: GraphQLNamedType, fullyQualifiedName: [String],
  selections: [CompilationResult.Selection]
) -> String {
  let isRoot = rootType == objectType
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  var existingSelections = [String: FieldKeyPosition]()
  var fieldPrimaryKeyPosition = [String: FieldKeyPosition]()
  for selection in selections {
    switch selection {
    case let .field(field):
      // Always replace it to inField
      existingSelections[field.name] = .inField
      if let selectionSet = field.selectionSet {
        fieldPrimaryKeyPosition[field.name] = primaryKeyPosition(
          objectType: selectionSet.parentType, selections: selectionSet.selections)
      }
    case let .inlineFragment(inlineFragment):
      let inlineFragmentType = inlineFragment.selectionSet.parentType
      guard inlineFragmentType == objectType else {
        continue
      }
      let selectionSet = inlineFragment.selectionSet
      for selection in selectionSet.selections {
        switch selection {
        case let .field(field):
          existingSelections[field.name] = .inInlineFragment(inlineFragmentType.name)
        case .inlineFragment(_), .fragmentSpread(_):
          break
        }
      }
    case let .fragmentSpread(fragmentSpread):
      let fragment = fragmentSpread.fragment
      let selectionSet = fragment.selectionSet
      let fragmentType = selectionSet.parentType
      for selection in selectionSet.selections {
        switch selection {
        case let .field(field):
          existingSelections[field.name] = .inFragmentSpread(
            fragmentSpread.fragment.name.pascalCase(),
            isOptionalFragments(fragmentType: fragmentType, objectType: objectType))
        case .inlineFragment(_), .fragmentSpread(_):
          break
        }
      }
    }
  }
  var emitPrimaryKey = false
  var fieldAssignments = [String]()
  for field in fields {
    guard existingFields.contains(field.name),
      let fieldKeyPosition = existingSelections[field.name]
    else {
      continue
    }
    let prefix: String
    switch fieldKeyPosition {
    case .inField, .noKey:
      prefix = ""
    case let .inInlineFragment(name):
      prefix = ".as\(name)?"
    case let .inFragmentSpread(name, optional):
      prefix = ".fragments.\(name.camelCase())\(optional ? "?" : "")"
    }
    guard field.name != primaryKey else {
      emitPrimaryKey = true
      if isRoot {
        fieldAssignments.append("\(field.name): obj.\(field.name.camelCase())")
      }
      continue
    }
    if namedType(field.type) == rootType {
      guard let primaryKeyPosition = fieldPrimaryKeyPosition[field.name],
        primaryKeyPosition != .noKey
      else { continue }
      switch field.type {
      case .named(_):
        fieldAssignments.append(
          "\(field.name): obj\(prefix).\(field.name.camelCase())?.\(primaryKey.camelCase())")
      case .nonNull(_):
        fieldAssignments.append(
          "\(field.name): obj\(prefix).\(field.name.camelCase()).\(primaryKey.camelCase())")
      case .list(_):
        fieldAssignments.append(
          "\(field.name): obj\(prefix).\(field.name.camelCase())?.compactMap { $0?.\(primaryKey.camelCase()) } ?? []"
        )
      }
    } else if isBaseType(field.type) {
      fieldAssignments.append(
        "\(field.name): \(unwrapType(prefix: "obj\(prefix).\(field.name.camelCase())", inner: "", type: field.type, optional: true))"
      )
    } else {
      let typeName = namedType(field.type).name
      fieldAssignments.append(
        "\(field.name): \(unwrapType(prefix: "obj\(prefix).\(field.name.camelCase())", inner: "\(rootType.name).\(typeName)($0)", type: field.type, optional: true))"
      )
    }
  }
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(objectType.name) {\n" : "extension \(objectType.name) {\n"
  if !emitPrimaryKey && primaryKey.count > 0 && isRoot {
    fieldAssignments.insert("\(primaryKey): \(primaryKey)", at: 0)
    if isRoot {
      inits += "  public convenience init(\(primaryKey): \(primaryKeyType), _ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    } else {
      inits += "  public init(\(primaryKey): \(primaryKeyType), _ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    }
  } else {
    if isRoot {
      inits += "  public convenience init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    } else {
      inits += "  public init(_ obj: \(fullyQualifiedName.joined(separator: "."))) {\n"
    }
  }
  inits += "    self.init(\(fieldAssignments.joined(separator: ", ")))\n"
  inits += "  }\n"
  inits += "}\n"
  return inits
}

func generateEnumInits(
  _ enumType: GraphQLEnumType,
  rootType: GraphQLNamedType
) -> String {
  let isRoot = rootType == enumType
  let values = enumType.values
  guard let defaultValue = values.first else { return "" }
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(enumType.name) {\n" : "extension \(enumType.name) {\n"
  inits += "  public init(_ obj: \(enumType.name)) {\n"
  inits += "    switch obj {\n"
  for value in values {
    inits += "    case .\(value.name.lowercased()):\n"
    inits += "      self = .\(value.name.lowercased())\n"
  }
  inits += "    case .__unknown(_):\n"
  inits += "      self = .\(defaultValue.name.lowercased())\n"
  inits += "    }\n"
  inits += "  }\n"
  inits += "}\n"
  return inits
}

func generateInits(
  _ entityType: GraphQLNamedType,
  rootType: GraphQLNamedType, fullyQualifiedName: [String],
  selections: [CompilationResult.Selection]
) -> String {
  if let interfaceType = entityType as? GraphQLInterfaceType {
    return generateInterfaceInits(
      interfaceType, rootType: rootType, fullyQualifiedName: fullyQualifiedName,
      selections: selections)
  } else if let objectType = entityType as? GraphQLObjectType {
    return generateObjectInits(
      objectType, rootType: rootType, fullyQualifiedName: fullyQualifiedName,
      selections: selections)
  } else if let enumType = entityType as? GraphQLEnumType {
    return generateEnumInits(enumType, rootType: rootType)
  } else {
    fatalError("Entity type has to be either an interface type, object type or enum type.")
  }
}

struct EntityInit {
  var entityType: GraphQLNamedType
  var rootType: GraphQLNamedType
  var fullyQualifiedName: [String]
  var selections: [CompilationResult.Selection]
}

func insertEntityInits(
  _ entityInits: inout [String: [String: [[String]: EntityInit]]], entityType: GraphQLNamedType,
  rootType: GraphQLNamedType, fullyQualifiedName: [String],
  selections: [CompilationResult.Selection]
) {
  if let _ = entityType as? GraphQLEnumType {
    // Remove fullyQualifiedName for enums.
    entityInits[rootType.name, default: [String: [[String]: EntityInit]]()][
      entityType.name, default: [[String]: EntityInit]()][[]] = EntityInit(
        entityType: entityType, rootType: rootType, fullyQualifiedName: [],
        selections: selections)
  } else {
    entityInits[rootType.name, default: [String: [[String]: EntityInit]]()][
      entityType.name, default: [[String]: EntityInit]()][fullyQualifiedName] = EntityInit(
        entityType: entityType, rootType: rootType, fullyQualifiedName: fullyQualifiedName,
        selections: selections)
    for namedType in getImplementations(from: entityType) {
      entityInits[rootType.name, default: [String: [[String]: EntityInit]]()][
        namedType.name, default: [[String]: EntityInit]()][fullyQualifiedName] = EntityInit(
          entityType: namedType, rootType: rootType, fullyQualifiedName: fullyQualifiedName,
          selections: selections)
    }
  }
}

func findEntityInits(
  entities: Set<String>,
  rootType: GraphQLNamedType?,
  fullyQualifiedName: [String],
  selectionSet: CompilationResult.SelectionSet,
  marked: Bool
) -> [String: [String: [[String]: EntityInit]]] {
  let entityName = selectionSet.parentType.name
  let hasEntity = entities.contains(entityName)
  var entityInits = [String: [String: [[String]: EntityInit]]]()
  let marked = marked || hasEntity
  guard let entityType = try? schema.getType(named: entityName) else { return entityInits }
  for selection in selectionSet.selections {
    switch selection {
    case let .field(field):
      if let selectionSet = field.selectionSet {
        if hasEntity {
          let newEntityInits = findEntityInits(
            entities: entities, rootType: entityType,
            fullyQualifiedName: fullyQualifiedName + [field.name.singularized().pascalCase()],
            selectionSet: selectionSet,
            marked: marked)
          entityInits.merge(newEntityInits) {
            $0.merging($1) { $0.merging($1) { data, _ in data } }
          }
        }
        let newEntityInits = findEntityInits(
          entities: entities, rootType: rootType,
          fullyQualifiedName: fullyQualifiedName + [field.name.singularized().pascalCase()],
          selectionSet: selectionSet,
          marked: marked)
        entityInits.merge(newEntityInits) { $0.merging($1) { $0.merging($1) { data, _ in data } } }
      } else if !isBaseType(field.type) && marked {  // This is pretty much only covers enum type, otherwise you need to have selectionSet.
        let fieldType = namedType(field.type)
        if hasEntity {
          insertEntityInits(
            &entityInits, entityType: fieldType, rootType: entityType,
            fullyQualifiedName: fullyQualifiedName, selections: selectionSet.selections)
        }
        if let rootType = rootType {
          insertEntityInits(
            &entityInits, entityType: fieldType, rootType: rootType,
            fullyQualifiedName: fullyQualifiedName, selections: selectionSet.selections)
        }
      }
    case let .inlineFragment(inlineFragment):
      if hasEntity {
        let newEntityInits = findEntityInits(
          entities: entities, rootType: entityType, fullyQualifiedName: fullyQualifiedName,
          selectionSet: inlineFragment.selectionSet,
          marked: marked)
        entityInits.merge(newEntityInits) { $0.merging($1) { $0.merging($1) { data, _ in data } } }
      }
      let newEntityInits = findEntityInits(
        entities: entities, rootType: rootType, fullyQualifiedName: fullyQualifiedName,
        selectionSet: inlineFragment.selectionSet,
        marked: marked)
      entityInits.merge(newEntityInits) { $0.merging($1) { $0.merging($1) { data, _ in data } } }
    case let .fragmentSpread(fragmentSpread):
      if hasEntity {
        let newEntityInits = findEntityInits(
          entities: entities, rootType: entityType,
          fullyQualifiedName: [fragmentSpread.fragment.name.pascalCase()],
          selectionSet: fragmentSpread.fragment.selectionSet,
          marked: marked)
        entityInits.merge(newEntityInits) { $0.merging($1) { $0.merging($1) { data, _ in data } } }
      }
      let newEntityInits = findEntityInits(
        entities: entities, rootType: rootType,
        fullyQualifiedName: [fragmentSpread.fragment.name.pascalCase()],
        selectionSet: fragmentSpread.fragment.selectionSet,
        marked: marked)
      entityInits.merge(newEntityInits) { $0.merging($1) { $0.merging($1) { data, _ in data } } }
    }
  }
  guard marked else { return entityInits }
  if hasEntity {
    insertEntityInits(
      &entityInits, entityType: entityType, rootType: entityType,
      fullyQualifiedName: fullyQualifiedName, selections: selectionSet.selections)
  }
  if let rootType = rootType {
    insertEntityInits(
      &entityInits, entityType: entityType, rootType: rootType,
      fullyQualifiedName: fullyQualifiedName, selections: selectionSet.selections)
  }
  return entityInits
}

var entityInits = [String: [String: [[String]: EntityInit]]]()
for operation in compilationResult.operations {
  let firstName: String
  switch operation.operationType {
  case .query:
    firstName = operation.name.pascalCase() + "Query"
  case .mutation:
    firstName = operation.name.pascalCase() + "Mutation"
  case .subscription:
    firstName = operation.name.pascalCase() + "Subscription"
  }
  let newEntityInits = findEntityInits(
    entities: Set(entities), rootType: nil, fullyQualifiedName: [firstName, "Data"],
    selectionSet: operation.selectionSet, marked: false)
  entityInits.merge(newEntityInits) { $0.merging($1) { $0.merging($1) { data, _ in data } } }
}

for entity in entities {
  let entityType = try schema.getType(named: entity)
  if let interfaceType = entityType as? GraphQLInterfaceType {
    let fbs = generateFlatbuffers(interfaceType)
    let outputPath = "\(outputDir!)/\(entity)_generated.fbs"
    try! fbs.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  } else if let objectType = entityType as? GraphQLObjectType {
    let fbs = generateFlatbuffers(objectType)
    let outputPath = "\(outputDir!)/\(entity)_generated.fbs"
    try! fbs.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  } else {
    fatalError("Root type has to be either an interface type or object type.")
  }
  if let inits = entityInits[entity] {
    let sourceCode: String = inits.sorted(by: { $0.key < $1.key }).map { $0.value }.reduce("") {
      $0
        + $1.sorted(by: {
          // Sort by array.
          if $0.key.count < $1.key.count {
            return true
          } else if $0.key.count > $1.key.count {
            return false
          }
          let count = $0.key.count
          for i in 0..<count {
            if $0.key[i] < $1.key[i] {
              return true
            } else if $0.key[i] > $1.key[i] {
              return false
            }
          }
          return true
        }).map { $0.value }.reduce("") {
          $0
            + generateInits(
              $1.entityType, rootType: $1.rootType, fullyQualifiedName: $1.fullyQualifiedName,
              selections: $1.selections)
        }
    }
    let outputPath = "\(outputDir!)/\(entity)_inits_generated.swift"
    try! sourceCode.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  }
}
