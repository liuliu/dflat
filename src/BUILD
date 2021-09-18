cc_library(
    name = "_SQLiteDflatOSShim",
    srcs = ["sqlite/os.c"],
    hdrs = ["sqlite/include/os.h"],
    includes = ["sqlite/include"],
    tags = ["swift_module=_SQLiteDflatOSShim"],
    visibility = ["//:__pkg__"],
)

filegroup(
    name = "DflatFiles",
    srcs = [
        "Atom.swift",
        "ChangeRequest.swift",
        "Expr.swift",
        "FetchedResult.swift",
        "FlatBuffersCodable.swift",
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
        "sqlite/OSShim.swift",
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
        "sqlite/SQLiteWorkspaceDictionary.swift",
        "sqlite/SQLiteWorkspaceState.swift",
        "sqlite/dict/dict_data_model_generated.swift",
        "sqlite/dict/dict_generated.swift",
        "sqlite/dict/dict_mutating_generated.swift",
        "sqlite/dict/dict_query_generated.swift",
    ],
    visibility = ["//:__pkg__"],
)
