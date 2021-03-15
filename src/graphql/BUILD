load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

package(
    default_visibility = ["//visibility:public"],
)

swift_binary(
    name = "codegen",
    srcs = ["codegen.swift"],
    deps = [
        "@apollo-ios//:ApolloCodegenLib",
    ],
)
