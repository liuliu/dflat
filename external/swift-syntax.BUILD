load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

cc_library(
    name = "_CSwiftSyntax",
    srcs = ["Sources/_CSwiftSyntax/src/atomic-counter.c"],
    hdrs = ["Sources/_CSwiftSyntax/include/atomic-counter.h"],
    includes = [
        "Sources/_CSwiftSyntax/include/",
    ],
    tags = ["swift_module=_CSwiftSyntax"],
)

swift_library(
    name = "SwiftSyntax",
    srcs = glob([
        "Sources/SwiftSyntax/**/*.swift",
    ]),
    module_name = "SwiftSyntax",
    visibility = ["//visibility:public"],
    deps = [
        ":_CSwiftSyntax",
    ],
)
