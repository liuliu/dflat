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
    "Expr.swift",
    "Workspace.swift",
    "Atom.swift",
    "ChangeRequest.swift",
    "QueryBuilder.swift",
    "FetchedResult.swift",
    "TransactionContext.swift",
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
    "sqlite/SQLiteConnection.swift",
    "sqlite/SQLiteConnectionPool.swift",
    "sqlite/SQLiteWorkspace.swift",
    "sqlite/SQLiteWorkspaceState.swift",
    "sqlite/SQLiteAtom.swift",
    "sqlite/SQLiteQueryBuilder.swift",
    "sqlite/SQLiteFetchedResult.swift",
    "sqlite/SQLitePersistenceToolbox.swift",
    "sqlite/SQLiteObjectRepository.swift",
    "sqlite/SQLiteTransactionContext.swift",
    "sqlite/SQLiteExpr.swift",
  ] + glob(["sqlite/exprs/*.swift"]),
  deps = [
    ":Dflat"
  ]
)
