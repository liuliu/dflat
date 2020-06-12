load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_test")

swift_library(
  name = "ExprTests_lib",
  srcs = [
    "ExprTests.swift",
  ],
  deps = [
    "//src:Dflat",
  ],
)

swift_library(
  name = "SQLiteWorkspaceTests_lib",
  srcs = [
    "monster_generated.swift",
    "Monster.swift",
    "MonsterChangeRequest.swift",
    "MonsterAttributes.swift",
    "SQLiteWorkspaceTests.swift",
  ],
  deps = [
    "//src:SQLiteDflat",
  ],
)

ios_unit_test(
  name = "Tests_ios",
  deps = [
    ":ExprTests_lib",
    ":SQLiteWorkspaceTests_lib",
  ],
  minimum_os_version = "10.0",
)

swift_test(
  name = "Tests",
  deps = [
    ":ExprTests_lib",
    ":SQLiteDflatTests_lib",
  ],
)
