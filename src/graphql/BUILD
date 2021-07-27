load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

swift_library(
    name = "ChangeCases",
    srcs = ["changeCases.swift"],
    module_name = "ChangeCases",
)

swift_binary(
    name = "codegen",
    srcs = ["codegen.swift"],
    deps = [
        ":ChangeCases",
        "@InflectorKit",
        "@apollo-ios//:ApolloCodegenLib",
    ],
)
