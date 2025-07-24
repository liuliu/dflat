load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_interop_hint")

cc_library(
    name = "CSystem",
    srcs = ["Sources/CSystem/shims.c"],
    hdrs = glob([
        "Sources/CSystem/include/*.h",
    ]),
    includes = [
        "Sources/CSystem/include/",
    ],
    tags = ["swift_module=CSystem"],
    aspect_hints = [":CSystem_swift_interop"],
)

swift_interop_hint(
    name = "CSystem_swift_interop",
    module_name = "CSystem",
)

swift_library(
    name = "SystemPackage",
    srcs = glob([
        "Sources/System/**/*.swift",
    ]),
    defines = [
        "_CRT_SECURE_NO_WARNINGS",
        "SYSTEM_PACKAGE",
    ],
    module_name = "SystemPackage",
    visibility = ["//visibility:public"],
    deps = [
        ":CSystem",
    ],
)
