load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_interop_hint")

cc_library(
    name = "_CSwiftSyntax",
    srcs = ["Sources/_CSwiftSyntax/src/atomic-counter.c"],
    hdrs = [
        "Sources/_CSwiftSyntax/include/atomic-counter.h",
        "Sources/_CSwiftSyntax/include/c-syntax-nodes.h",
    ],
    includes = [
        "Sources/_CSwiftSyntax/include/",
    ],
    tags = ["swift_module=_CSwiftSyntax"],
    aspect_hints = [":CSwiftSyntax_swift_interop"],
)

swift_interop_hint(
    name = "CSwiftSyntax_swift_interop",
    module_name = "CSwiftSyntax",
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

swift_library(
    name = "SwiftSyntaxBuilder",
    srcs = glob([
        "Sources/SwiftSyntaxBuilder/**/*.swift",
    ]),
    module_name = "SwiftSyntaxBuilder",
    visibility = ["//visibility:public"],
    deps = [
        ":SwiftSyntax",
    ],
)

swift_library(
    name = "SwiftSyntaxParser",
    srcs = glob([
        "Sources/SwiftSyntaxParser/**/*.swift",
    ]),
    module_name = "SwiftSyntaxParser",
    visibility = ["//visibility:public"],
    deps = [
        ":SwiftSyntax",
    ],
)
