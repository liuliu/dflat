load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
  default_visibility = ["//visibility:public"],
)

objc_library(
  name = "CAtomics",
  hdrs = ["Sources/CAtomics/include/CAtomics.h"],
  enable_modules = True,
  module_name = "CAtomics"
)

swift_library(
  name = "SwiftAtomics",
  module_name = "SwiftAtomics",
  srcs = [
    "Sources/SwiftAtomics/atomics-integer.swift",
    "Sources/SwiftAtomics/atomics-orderings.swift",
  ],
  deps = [
    ":CAtomics",
  ]
)
