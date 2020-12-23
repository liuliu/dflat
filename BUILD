licenses(["notice"])

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

exports_files([
    "LICENSE",
])

swift_library(
    name = "Dflat",
    srcs = ["//src:DflatFiles"],
    module_name = "Dflat",
    deps = [
        "@flatbuffers//:FlatBuffers",
        "@swift-atomics//:SwiftAtomics",
    ],
)

config_setting(
    name = "linux_build",
    constraint_values = [
        "@platforms//os:linux",
    ],
)

swift_library(
    name = "SQLiteDflat",
    srcs = ["//src:SQLiteDflatFiles"],
    module_name = "SQLiteDflat",
    deps = [
        ":Dflat",
        "//src:_SQLiteDflatOSShim",
    ] + select({
        ":linux_build": ["@sqlite3//:SQLite3"],
        "//conditions:default": [],
    }),
)
