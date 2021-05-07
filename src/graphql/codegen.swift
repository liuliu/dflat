import Foundation

@testable import ApolloCodegenLib

let bundle = Bundle(for: ApolloCodegenFrontend.self)
if let resourceUrl = bundle.resourceURL,
  let bazelResourceUrl = bundle.url(
    forResource: "ApolloCodegenFrontend.bundle", withExtension: "js",
    subdirectory: "codegen.runfiles/apollo-ios/Sources/ApolloCodegenLib/Frontend/JavaScript/dist")
{
  let standardUrl = resourceUrl.appendingPathComponent("ApolloCodegenFrontend.bundle.js")
  try? FileManager.default.linkItem(at: bazelResourceUrl, to: standardUrl)
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
  fbs += "table \(objectType.name) {\n"
  let fields = objectType.fields.values.sorted(by: { $0.name < $1.name })
  for field in fields {
    guard existingFields.contains(field.name) else { continue }
    guard field.name != "id" else {
      if rootType == objectType {
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
    if rootType == interfaceType {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType)) (primary);\n"
    } else {
      fbs += "  \(field.name): \(flatbuffersType(field.type, rootType: rootType));\n"
    }
  }
  fbs += "}\n"
  return fbs
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

func generateInits(
  entities: Set<String>,
  selectionSet: CompilationResult.SelectionSet, marked: Bool
) {
  let typeName = selectionSet.parentType.name
  let marked = marked || entities.contains(typeName)
  for selection in selectionSet.selections {
    switch selection {
    case let .field(field):
      print("field: \(field.name)")
      if marked {
      }
      if let selectionSet = field.selectionSet {
        generateInits(
          entities: entities, selectionSet: selectionSet,
          marked: marked)
      }
    case let .inlineFragment(inlineFragment):
      print("inline fragment \(inlineFragment.selectionSet.parentType as Optional)")
      generateInits(
        entities: entities, selectionSet: inlineFragment.selectionSet,
        marked: marked)
    case let .fragmentSpread(fragmentSpread):
      print("fragment spread")
      generateInits(
        entities: entities,
        selectionSet: fragmentSpread.fragment.selectionSet, marked: marked)
      break
    }
  }
}

for operation in compilationResult.operations {
  print("-- operation: \(operation.name)")
  generateInits(
    entities: Set(entities), selectionSet: operation.selectionSet,
    marked: false)
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
}
