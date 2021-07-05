import Foundation
import InflectorKit

@testable import ApolloCodegenLib

extension String {
  func firstLowercased() -> String {
    prefix(1).lowercased() + dropFirst()
  }
  func firstUppercased() -> String {
    prefix(1).uppercased() + dropFirst()
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

let schemaPath = CommandLine.arguments[1]
var documentPaths = [String]()
var entities = [String]()
var outputDir: String? = nil
enum CommandOptions {
  case document
  case entity
  case output
}
var options = CommandOptions.document
for argument in CommandLine.arguments[2...] {
  if argument == "--entity" {
    options = .entity
  } else if argument == "-o" {
    options = .output
  } else {
    switch options {
    case .document:
      documentPaths.append(argument)
    case .entity:
      entities.append(argument)
    case .output:
      outputDir = argument
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

func generateObjectType(_ objectType: GraphQLObjectType, rootType: GraphQLNamedType) -> String {
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  var fbs = ""
  let isRoot = rootType == objectType
  fbs += "table \(objectType.name) {\n"
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name != "id" else {
      if isRoot {
        fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
      }
      continue
    }
    fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
  }
  fbs += "}\n"
  return fbs
}

func generateInterfaceType(_ interfaceType: GraphQLInterfaceType, rootType: GraphQLNamedType)
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
  fbs += "table \(interfaceType.name) {\n"
  if implementations.objects.count > 0 {
    fbs +=
      isRoot
      ? "  subtype: \(interfaceType.name).Subtype;\n" : "  subtype: \(interfaceType.name)Subtype;\n"
  }
  let fields = interfaceType.fields.values.sorted(by: { $0.name < $1.name })
  let existingFields = objectFields[interfaceType.name]!
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name == "id" else { continue }
    if isRoot {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
    } else {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
    }
  }
  fbs += "}\n"
  return fbs
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

func generateFlatbuffers(_ rootType: GraphQLInterfaceType) -> String {
  var array = [GraphQLNamedType]()
  var set = Set<String>()
  set.insert(rootType.name)
  referencedTypes(rootType: rootType, set: &set, &array)
  set.removeAll()
  set.insert(rootType.name)
  var fbs = "namespace \(rootType.name);\n"
  for entityType in array.reversed() {
    guard !set.contains(entityType.name) else { continue }
    set.insert(entityType.name)
    if let interfaceType = entityType as? GraphQLInterfaceType {
      fbs += generateInterfaceType(interfaceType, rootType: rootType)
    } else if let objectType = entityType as? GraphQLObjectType {
      fbs += generateObjectType(objectType, rootType: rootType)
    } else if let enumType = entityType as? GraphQLEnumType {
      fbs += generateEnumType(enumType)
    }
  }
  fbs += generateInterfaceType(rootType, rootType: rootType)
  fbs += "root_type \(rootType.name);\n"
  return fbs
}

func generateFlatbuffers(_ rootType: GraphQLObjectType) -> String {
  var array = [GraphQLNamedType]()
  var set = Set<String>()
  set.insert(rootType.name)
  referencedTypes(rootType: rootType, set: &set, &array)
  set.removeAll()
  set.insert(rootType.name)
  var fbs = "namespace \(rootType.name);\n"
  for entityType in array.reversed() {
    guard !set.contains(entityType.name) else { continue }
    set.insert(entityType.name)
    if let interfaceType = entityType as? GraphQLInterfaceType {
      fbs += generateInterfaceType(interfaceType, rootType: rootType)
    } else if let objectType = entityType as? GraphQLObjectType {
      fbs += generateObjectType(objectType, rootType: rootType)
    } else if let enumType = entityType as? GraphQLEnumType {
      fbs += generateEnumType(enumType)
    }
  }
  fbs += generateObjectType(rootType, rootType: rootType)
  fbs += "root_type \(rootType.name);\n"
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

func generateInterfaceInits(
  _ interfaceType: GraphQLInterfaceType,
  rootType: GraphQLNamedType, namespaces: [String],
  selections: [CompilationResult.Selection]
) -> String {
  let isRoot = rootType == interfaceType
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(interfaceType.name) {\n" : "extension \(interfaceType.name) {\n"
  if isRoot {
    inits += "  public convenience init(_ obj: \(namespaces.joined(separator: "."))) {\n"
  } else {
    inits += "  public init(_ obj: \(namespaces.joined(separator: "."))) {\n"
  }
  inits += "    self.init(id: obj.id, subtype: .init(obj))\n"
  inits += "  }\n"
  inits += "}\n"
  let implementations = try! schema.getImplementations(interfaceType: interfaceType)
  guard implementations.objects.count > 0 else { return inits }
  inits +=
    !isRoot
    ? "extension \(rootType.name).\(interfaceType.name)Subtype {\n"
    : "extension \(interfaceType.name).Subtype {\n"
  inits += "  public init?(_ obj: \(namespaces.joined(separator: "."))) {\n"
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
  for object in implementations.objects {
    inits += generateObjectInits(
      object, rootType: rootType, namespaces: namespaces, selections: selections)
  }
  return inits
}

func generateObjectInits(
  _ objectType: GraphQLObjectType,
  rootType: GraphQLNamedType, namespaces: [String],
  selections: [CompilationResult.Selection]
) -> String {
  let isRoot = rootType == objectType
  var inits =
    !isRoot
    ? "extension \(rootType.name).\(objectType.name) {\n" : "extension \(objectType.name) {\n"
  if isRoot {
    inits += "  public convenience init(_ obj: \(namespaces.joined(separator: "."))) {\n"
  } else {
    inits += "  public init(_ obj: \(namespaces.joined(separator: "."))) {\n"
  }
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  var existingFields = objectFields[objectType.name]!
  for interfaceType in objectType.interfaces {
    existingFields.formUnion(objectFields[interfaceType.name]!)
  }
  var existingSelections = Set<String>()
  var fieldSelectionSet = [String: CompilationResult.SelectionSet]()
  for selection in selections {
    switch selection {
    case let .field(field):
      existingSelections.insert(field.name)
      fieldSelectionSet[field.name] = field.selectionSet
    case .inlineFragment(_):
      break
    case .fragmentSpread(_):
      break
    }
  }
  var fieldAssignments = [String]()
  for field in fields {
    guard existingFields.contains(field.name) && existingSelections.contains(field.name) else {
      continue
    }
    guard field.name != "id" else {
      if isRoot {
        fieldAssignments.append("\(field.name): obj.\(field.name)")
      }
      continue
    }
    if namedType(field.type) == rootType {
      guard let selectionSet = fieldSelectionSet[field.name],
        (selectionSet.selections.contains {
          guard case let .field(field) = $0 else { return false }
          return field.name == "id"
        })
      else { continue }
      switch field.type {
      case .named(_):
        fieldAssignments.append("\(field.name): obj.\(field.name)?.id")
      case .nonNull(_):
        fieldAssignments.append("\(field.name): obj.\(field.name).id")
      case .list(_):
        fieldAssignments.append("\(field.name): obj.\(field.name)?.compactMap { $0?.id } ?? []")
      }
    } else if isBaseType(field.type) {
      fieldAssignments.append("\(field.name): obj.\(field.name)")
    } else {
      fieldAssignments.append("\(field.name): .init(obj.\(field.name))")
    }
  }
  inits += "    self.init(\(fieldAssignments.joined(separator: ", ")))\n"
  inits += "  }\n"
  inits += "}\n"
  return inits
}

func generateInits(
  entities: Set<String>, namespaces: [String],
  selectionSet: CompilationResult.SelectionSet, entityName: String?,
  entityInits: inout [String: String]
) {
  let typeName = selectionSet.parentType.name
  let entityName = entities.contains(typeName) ? typeName : entityName
  var hasID = false
  for selection in selectionSet.selections {
    switch selection {
    case let .field(field):
      print("field: \(field.name), \(field.type)")
      if field.name == "id" && isIDType(field.type) {
        hasID = true
      }
      if let selectionSet = field.selectionSet {
        generateInits(
          entities: entities,
          namespaces: namespaces + [field.name.firstUppercased().singularized()],
          selectionSet: selectionSet, entityName: entityName, entityInits: &entityInits)
      }
    case let .inlineFragment(inlineFragment):
      print("inline fragment \(inlineFragment.selectionSet.parentType as Optional)")
      generateInits(
        entities: entities, namespaces: namespaces,
        selectionSet: inlineFragment.selectionSet, entityName: entityName, entityInits: &entityInits
      )
    case let .fragmentSpread(fragmentSpread):
      print("fragment spread")
      generateInits(
        entities: entities, namespaces: namespaces,
        selectionSet: fragmentSpread.fragment.selectionSet, entityName: entityName,
        entityInits: &entityInits)
      break
    }
  }
  guard hasID, let entityName = entityName, let entityType = try? schema.getType(named: entityName)
  else { return }
  if let interfaceType = entityType as? GraphQLInterfaceType {
    entityInits[entityName, default: ""] += generateInterfaceInits(
      interfaceType, rootType: entityType, namespaces: namespaces,
      selections: selectionSet.selections)
  } else if let objectType = entityType as? GraphQLObjectType {
    entityInits[entityName, default: ""] += generateObjectInits(
      objectType, rootType: entityType, namespaces: namespaces, selections: selectionSet.selections)
  } else {
    fatalError("Entity type has to be either an interface type or object type.")
  }
}

var entityInits = [String: String]()
for operation in compilationResult.operations {
  let firstNamespace: String
  switch operation.operationType {
  case .query:
    firstNamespace = operation.name + "Query"
  case .mutation:
    firstNamespace = operation.name + "Mutation"
  case .subscription:
    firstNamespace = operation.name + "Subscription"
  }
  print("-- operation: \(operation.name)")
  generateInits(
    entities: Set(entities), namespaces: [firstNamespace, "Data"],
    selectionSet: operation.selectionSet, entityName: nil, entityInits: &entityInits)
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
    let outputPath = "\(outputDir!)/\(entity)_inits_generated.swift"
    try! inits.write(
      to: URL(fileURLWithPath: outputPath), atomically: false, encoding: String.Encoding.utf8)
  }
}
