load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
  name = "FlatBuffers",
  module_name = "FlatBuffers",
  srcs = glob(["FlatBuffers/*.swift"]),
)

objc_library(
  name = "CAtomics",
  hdrs = ["CAtomics/CAtomics.h"],
  enable_modules = True,
  module_name = "CAtomics"
)

swift_library(
  name = "SwiftAtomics",
  module_name = "SwiftAtomics",
  srcs = [
    "SwiftAtomics/AtomicInt.swift",
    "SwiftAtomics/MemoryOrder.swift",
  ],
  deps = [
    ":CAtomics",
  ]
)

swift_library(
  name = "Dflat",
  module_name = "Dflat",
  visibility = ["//visibility:public"],
  srcs = [
    "Atom.swift",
    "ChangeRequest.swift",
    "Expr.swift",
    "FetchedResult.swift",
    "Publisher.swift",
    "QueryBuilder.swift",
    "TransactionContext.swift",
    "Workspace.swift",
  ] + glob(["exprs/*.swift"]),
  deps = [
    ":FlatBuffers",
    ":SwiftAtomics",
  ]
)

swift_library(
  name = "SQLiteDflat",
  module_name = "SQLiteDflat",
  visibility = ["//visibility:public"],
  srcs = [
    "sqlite/SQLiteAtom.swift",
    "sqlite/SQLiteConnection.swift",
    "sqlite/SQLiteConnectionPool.swift",
    "sqlite/SQLiteExpr.swift",
    "sqlite/SQLiteFetchedResult.swift",
    "sqlite/SQLiteObjectRepository.swift",
    "sqlite/SQLitePersistenceToolbox.swift",
    "sqlite/SQLitePublisher.swift",
    "sqlite/SQLiteQueryBuilder.swift",
    "sqlite/SQLiteResultPublisher.swift",
    "sqlite/SQLiteTableSpace.swift",
    "sqlite/SQLiteTableState.swift",
    "sqlite/SQLiteTransactionContext.swift",
    "sqlite/SQLiteWorkspace.swift",
    "sqlite/SQLiteWorkspaceState.swift",
  ] + glob(["sqlite/exprs/*.swift"]),
  deps = [
    ":Dflat"
  ]
)
