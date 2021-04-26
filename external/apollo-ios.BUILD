load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

swift_library(
    name = "ApolloCore",
    srcs = glob([
        "Sources/ApolloCore/**/*.swift",
    ]),
    module_name = "ApolloCore",
    deps = [
    ],
)

swift_library(
    name = "Apollo",
    srcs = glob([
        "Sources/Apollo/**/*.swift",
    ]),
    module_name = "Apollo",
    deps = [
        ":ApolloCore",
    ],
)

swift_library(
    name = "ApolloCodegenLib",
    srcs = glob([
        "Sources/ApolloCodegenLib/**/*.swift",
    ]),
    data = [
        "Sources/ApolloCodegenLib/Frontend/JavaScript/dist/ApolloCodegenFrontend.bundle.js",
    ],
    module_name = "ApolloCodegenLib",
    deps = [
        ":ApolloCore",
        "@InflectorKit",
        "@Stencil",
    ],
)
