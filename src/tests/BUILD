load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_test")

swift_library(
  name = "Tests_lib",
  srcs = [
    "monster_generated.swift",
    "Monster.swift",
    "MonsterChangeRequest.swift",
    "MonsterAttributes.swift",
    "SQLiteWorkspaceCRUDTests.swift",
    "SubscribeTests.swift",
    "ObjectRepositoryTests.swift",
    "ExprTests.swift",
  ],
  deps = [
    "//src:SQLiteDflat",
  ],
)

ios_unit_test(
  name = "Tests",
  deps = [
    ":Tests_lib",
  ],
  minimum_os_version = "10.0",
)
