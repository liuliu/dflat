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
  module_name = "Dflat",
  srcs = ["//src:DflatFiles"],
  deps = [
    "@flatbuffers//:FlatBuffers",
    "@swift-atomics//:SwiftAtomics"
  ]
)

swift_library(
  name = "SQLiteDflat",
  module_name = "SQLiteDflat",
  srcs = ["//src:SQLiteDflatFiles"],
  deps = [
    ":Dflat",
    "//src:SQLiteDflatObjC"
  ]
)
