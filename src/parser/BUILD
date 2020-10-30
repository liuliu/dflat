load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

package(
  default_visibility = ["//visibility:public"],
)

cc_binary(
  name = "dflats",
  srcs = ["dflats.cpp"],
  deps = ["@flatbuffers//:flatc"],
)

swift_binary(
  name = "dflatc",
  srcs = ["dflatc.swift"],
)
