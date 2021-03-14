load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

swift_library(
    name = "Stencil",
    srcs = glob([
        "Sources/*.swift",
    ]),
    module_name = "Stencil",
    deps = [
        "@PathKit",
    ],
)
