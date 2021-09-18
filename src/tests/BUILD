load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")
load("@dflat//:dflat.bzl", "dflatc")

filegroup(
    name = "OrbWeapon_Sources",
    srcs = ["orb_weapon.fbs"],
)

dflatc(
    name = "monster_schema",
    srcs = [
        "monster.fbs",
        "monster_v2.fbs",
        "monster_v3.fbs",
    ],
    includes = [":OrbWeapon_Sources"],
)

dflatc(
    name = "orb_weapon_schema",
    srcs = [":OrbWeapon_Sources"],
)

swift_library(
    name = "Tests_lib",
    srcs = [
        "ConcurrencyTests.swift",
        "ExprTests.swift",
        "FetchTests.swift",
        "ObjectRepositoryTests.swift",
        "SQLiteWorkspaceCRUDTests.swift",
        "SchemaUpgradeTests.swift",
        "SubscribeTests.swift",
        "main.swift",
        "namespace.swift",
        ":monster_schema",
        ":orb_weapon_schema",
    ],
    deps = [
        "//:SQLiteDflat",
    ],
)

swift_test(
    name = "Tests",
    deps = [
        ":Tests_lib",
    ],
)

ios_unit_test(
    name = "iOSTests",
    minimum_os_version = "10.0",
    deps = [
        ":Tests_lib",
    ],
)
