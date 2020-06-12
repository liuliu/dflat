load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
  name = "FlatBuffers",
  module_name = "FlatBuffers",
  srcs = glob(["FlatBuffers/*.swift"]),
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
    "sqlite/SQLiteAtom.swift",
    "sqlite/SQLiteQueryBuilder.swift",
    "sqlite/SQLiteFetchedResult.swift",
    "sqlite/SQLitePersistenceToolbox.swift",
    "sqlite/SQLiteTransactionContext.swift",
    "sqlite/SQLiteExpr.swift",
  ] + glob(["sqlite/exprs/*.swift"]),
  deps = [
    ":Dflat"
  ]
)
