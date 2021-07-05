load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

swift_library(
    name = "ApolloUtils",
    srcs = glob([
        "Sources/ApolloUtils/**/*.swift",
    ]),
    module_name = "ApolloUtils",
    deps = [
    ],
)

swift_library(
    name = "ApolloAPI",
    srcs = glob([
        "Sources/ApolloAPI/*.swift",
    ]),
    module_name = "ApolloAPI",
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
        ":ApolloAPI",
        ":ApolloUtils",
    ],
)

swift_library(
    name = "ApolloCodegenLib",
    srcs = glob([
        "Sources/ApolloCodegenLib/**/*.swift",
    ]),
    data = [
        "Sources/ApolloCodegenLib/Frontend/dist/ApolloCodegenFrontend.bundle.js",
        "Sources/ApolloCodegenLib/Frontend/dist/ApolloCodegenFrontend.bundle.js.map",
    ],
    module_name = "ApolloCodegenLib",
    deps = [
        ":ApolloUtils",
        "@InflectorKit",
        "@Stencil",
    ],
)
