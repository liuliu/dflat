load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_interop_hint")

cc_library(
    name = "_AtomicsShims",
    srcs = ["Sources/_AtomicsShims/src/_AtomicsShims.c"],
    hdrs = ["Sources/_AtomicsShims/include/_AtomicsShims.h"],
    includes = [
        "Sources/_AtomicsShims/include/",
    ],
    tags = ["swift_module=_AtomicsShims"],
    aspect_hints = [":AtomicsShims_swift_interop"],
)

swift_interop_hint(
    name = "AtomicsShims_swift_interop",
    module_name = "AtomicsShims",
)

swift_library(
    name = "SwiftAtomics",
    srcs = glob([
        "Sources/Atomics/**/*.swift",
    ]),
    module_name = "Atomics",
    visibility = ["//visibility:public"],
    deps = [
        ":_AtomicsShims",
    ],
    alwayslink = True,
)
