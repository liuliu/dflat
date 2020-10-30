load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")
load("@dflat//:dflat.bzl", "dflatc")

dflatc(
  name = "monster_schema",
  src = "monster.fbs",
  includes = ["orb_weapon.fbs"]
)

dflatc(
  name = "orb_weapon_schema",
  src = "orb_weapon.fbs"
)

dflatc(
  name = "monster_v2_schema",
  src = "monster_v2.fbs"
)

swift_library(
  name = "Tests_lib",
  srcs = [
    "ConcurrencyTests.swift",
    "ExprTests.swift",
    "FetchTests.swift",
    "namespace.swift",
    ":monster_schema",
    ":orb_weapon_schema",
    ":monster_v2_schema",
    "ObjectRepositoryTests.swift",
    "SchemaUpgradeTests.swift",
    "SQLiteWorkspaceCRUDTests.swift",
    "SubscribeTests.swift",
    "main.swift"
  ],
  deps = [
    "//:SQLiteDflat",
  ],
)

swift_test(
  name = "Tests",
  deps = [
    ":Tests_lib"
  ]
)

ios_unit_test(
  name = "iOSTests",
  deps = [
    ":Tests_lib"
  ],
  minimum_os_version = "10.0",
)
