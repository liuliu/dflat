load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
  default_visibility = ["//visibility:public"],
)

cc_library(
  name = "_AtomicsShims",
  hdrs = ["Sources/_AtomicsShims/include/_AtomicsShims.h"],
  srcs = ["Sources/_AtomicsShims/src/_AtomicsShims.c"],
  tags = ["swift_module=_AtomicsShims"],
  includes = [
    "Sources/_AtomicsShims/include/"
  ]
)

swift_library(
  name = "SwiftAtomics",
  module_name = "Atomics",
  srcs = glob([
    "Sources/Atomics/**/*.swift"
  ]),
  deps = [
    ":_AtomicsShims",
  ]
)
