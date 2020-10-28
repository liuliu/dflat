// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let dependencies: [Package.Dependency] = [
    .package(name: "FlatBuffers", url: "https://github.com/mustiikhalil/flatbuffers.git", from: "0.8.0"),
    .package(url: "https://github.com/apple/swift-atomics.git", from: "0.0.2"),
    .package(url: "https://github.com/liuliu/swift-sqlite3-support.git", from: "5.3.0")
  ]
#else
let dependencies: [Package.Dependency] = [
    .package(name: "FlatBuffers", url: "https://github.com/mustiikhalil/flatbuffers.git", from: "0.8.0"),
    .package(url: "https://github.com/apple/swift-atomics.git", from: "0.0.2")
  ]
#endif

let package = Package(
  name: "Dflat",
  platforms: [.macOS(.v10_14), .iOS(.v11), .watchOS(.v3), .tvOS(.v10)],
  products: [
    .library(name: "Dflat", type: .static, targets: ["Dflat"]),
    .library(name: "SQLiteDflat", type: .static, targets: ["SQLiteDflat"]),
  ],
  dependencies: dependencies,
  targets: [
    .target(
      name: "Dflat",
      dependencies: ["FlatBuffers", .product(name: "Atomics", package: "swift-atomics")],
      path: "src",
      sources: [
        "Atom.swift",
        "ChangeRequest.swift",
        "Expr.swift",
        "FetchedResult.swift",
        "Publisher.swift",
        "QueryBuilder.swift",
        "SQLiteExpr.swift",
        "TransactionContext.swift",
        "Workspace.swift",
        "exprs/Addition.swift",
        "exprs/Field.swift",
        "exprs/In.swift",
        "exprs/LessThan.swift",
        "exprs/Not.swift",
        "exprs/Or.swift",
        "exprs/And.swift",
        "exprs/IsNotNull.swift",
        "exprs/LessThanOrEqualTo.swift",
        "exprs/NotEqualTo.swift",
        "exprs/Subtraction.swift",
        "exprs/EqualTo.swift",
        "exprs/IsNull.swift",
        "exprs/Mod.swift",
        "exprs/NotIn.swift",
        "exprs/Value.swift",
        "exprs/sqlite/SQLiteAddition.swift",
        "exprs/sqlite/SQLiteField.swift",
        "exprs/sqlite/SQLiteIn.swift",
        "exprs/sqlite/SQLiteLessThan.swift",
        "exprs/sqlite/SQLiteNot.swift",
        "exprs/sqlite/SQLiteOr.swift",
        "exprs/sqlite/SQLiteAnd.swift",
        "exprs/sqlite/SQLiteIsNotNull.swift",
        "exprs/sqlite/SQLiteLessThanOrEqualTo.swift",
        "exprs/sqlite/SQLiteNotEqualTo.swift",
        "exprs/sqlite/SQLiteSubtraction.swift",
        "exprs/sqlite/SQLiteEqualTo.swift",
        "exprs/sqlite/SQLiteIsNull.swift",
        "exprs/sqlite/SQLiteMod.swift",
        "exprs/sqlite/SQLiteNotIn.swift",
        "exprs/sqlite/SQLiteValue.swift"
      ]),
    .target(
      name: "_SQLiteDflatOSShim",
      path: "src/sqlite",
      sources: [
        "os.c",
      ],
      publicHeadersPath: "include"),
    .target(
      name: "SQLiteDflat",
      dependencies: ["Dflat", "_SQLiteDflatOSShim"],
      path: "src/sqlite",
      sources: [
        "SQLiteAtom.swift",
        "SQLiteConnection.swift",
        "SQLiteConnectionPool.swift",
        "SQLiteExpr.swift",
        "SQLiteFetchedResult.swift",
        "SQLiteObjectRepository.swift",
        "SQLitePersistenceToolbox.swift",
        "SQLitePublisher.swift",
        "SQLiteQueryBuilder.swift",
        "SQLiteResultPublisher.swift",
        "SQLiteTableSpace.swift",
        "SQLiteTableState.swift",
        "SQLiteTransactionContext.swift",
        "SQLiteValue.swift",
        "SQLiteWorkspace.swift",
        "SQLiteWorkspaceState.swift",
        "OSShim.swift"
      ]),
    .testTarget(
      name: "Tests",
      dependencies: ["SQLiteDflat"],
      path: "src/tests",
      sources: [
        "ConcurrencyTests.swift",
        "ExprTests.swift",
        "FetchTests.swift",
        "namespace.swift",
        "monster_generated.swift",
        "monster_data_model_generated.swift",
        "monster_mutating_generated.swift",
        "monster_query_generated.swift",
        "orb_weapon_generated.swift",
        "orb_weapon_data_model_generated.swift",
        "orb_weapon_mutating_generated.swift",
        "monster_v2_generated.swift",
        "monster_v2_data_model_generated.swift",
        "monster_v2_mutating_generated.swift",
        "monster_v2_query_generated.swift",
        "ObjectRepositoryTests.swift",
        "SchemaUpgradeTests.swift",
        "SQLiteWorkspaceCRUDTests.swift",
        "SubscribeTests.swift"
      ])
  ]
)
