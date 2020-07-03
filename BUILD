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
  private_deps = [
    "@swift-atomics//:SwiftAtomics"
  ],
  deps = [
    "@flatbuffers//:FlatBuffers"
  ]
)

swift_library(
  name = "SQLiteDflat",
  module_name = "SQLiteDflat",
  srcs = ["//src:SQLiteDflatFiles"],
  private_deps = [
    "@swift-atomics//:SwiftAtomics"
  ],
  deps = [
    ":Dflat",
    "//src:SQLiteDflatObjC"
  ]
)
