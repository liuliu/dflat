load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")
load("@dflat//:dflat.bzl", "dflatc")

dflatc(
    name = "Character_generated_schema",
    src = "Character_generated.fbs",
)

swift_library(
    name = "Tests_lib",
    srcs = [
        "API.swift",
        "GraphQLTests.swift",
        "main.swift",
        ":Character_generated_schema",
    ],
    deps = [
        "//:SQLiteDflat",
        "@apollo-ios//:Apollo",
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
