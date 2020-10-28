cc_library(
  name = "_SQLiteDflatOSShim",
  hdrs = ["sqlite/include/os.h"],
  srcs = ["sqlite/os.c"],
  tags = ["swift_module=_SQLiteDflatOSShim"],
  includes = ["sqlite/include"],
  visibility = ["//:__pkg__"]
)

filegroup(
  name = "DflatFiles",
  srcs = [
    "Atom.swift",
    "ChangeRequest.swift",
    "Expr.swift",
    "FetchedResult.swift",
    "Publisher.swift",
    "QueryBuilder.swift",
    "SQLiteExpr.swift",
    "TransactionContext.swift",
    "Workspace.swift",
  ] + glob(["exprs/**/*.swift"]),
  visibility = ["//:__pkg__"],
)

filegroup(
  name = "SQLiteDflatFiles",
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
    "sqlite/SQLiteValue.swift",
    "sqlite/SQLiteWorkspace.swift",
    "sqlite/SQLiteWorkspaceState.swift",
    "sqlite/OSShim.swift",
  ],
  visibility = ["//:__pkg__"],
)
