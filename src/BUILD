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
    "Dflat.swift",
    "DflatAtom.swift",
    "DflatChangeRequest.swift",
    "DflatQueryBuilder.swift",
    "DflatFetchedResult.swift",
    "DflatTransactionContext.swift",
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
    "sqlite/SQLiteDflat.swift",
    "sqlite/SQLiteDflatAtom.swift",
    "sqlite/SQLiteDflatQueryBuilder.swift",
    "sqlite/SQLiteDflatFetchedResult.swift",
    "sqlite/SQLiteDflatTransactionContext.swift",
    "sqlite/SQLiteExpr.swift",
  ] + glob(["sqlite/exprs/*.swift"]),
  deps = [
    ":Dflat"
  ]
)
