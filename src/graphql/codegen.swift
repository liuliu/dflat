import Foundation

@testable import ApolloCodegenLib

let bundle = Bundle(for: ApolloCodegenFrontend.self)
if let resourceUrl = bundle.resourceURL,
  let bazelResourceUrl = bundle.url(
    forResource: "ApolloCodegenFrontend.bundle", withExtension: "js",
    subdirectory: "schema.runfiles/apollo-ios/Sources/ApolloCodegenLib/Frontend/JavaScript/dist")
{
  let standardUrl = resourceUrl.appendingPathComponent("ApolloCodegenFrontend.bundle.js")
  try? FileManager.default.linkItem(at: bazelResourceUrl, to: standardUrl)
}

let codegenFrontend = try ApolloCodegenFrontend()

let schemaPath = CommandLine.arguments[1]
var documentPaths = [String]()
var entities = [String]()
var outputPath = ""
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
      outputPath = argument
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

// First, generate the flatbuffers schema file. One file per entity.

for entity in entities {
  let entityType = try schema.getType(named: entity)
  if let interfaceType = entityType as? GraphQLInterfaceType {
    print(interfaceType.fields)
  } else if let objectType = entityType as? GraphQLObjectType {
    print(objectType.fields)
  } else {
    fatalError("Root type has to be either an interface type or object type.")
  }
}

print(objectFields)
