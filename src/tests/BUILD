load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")

swift_library(
  name = "Tests_lib",
  srcs = [
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
    "SubscribeTests.swift",
    "LinuxMain.swift"
  ],
  deps = [
    "//:SQLiteDflat",
  ],
)

ios_unit_test(
  name = "Tests",
  deps = [
    ":Tests_lib",
  ],
  minimum_os_version = "10.0",
)
