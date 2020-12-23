load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "_AtomicsShims",
    srcs = ["Sources/_AtomicsShims/src/_AtomicsShims.c"],
    hdrs = ["Sources/_AtomicsShims/include/_AtomicsShims.h"],
    includes = [
        "Sources/_AtomicsShims/include/",
    ],
    tags = ["swift_module=_AtomicsShims"],
)

swift_library(
    name = "SwiftAtomics",
    srcs = glob([
        "Sources/Atomics/**/*.swift",
    ]),
    module_name = "Atomics",
    deps = [
        ":_AtomicsShims",
    ],
)
