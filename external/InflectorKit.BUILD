load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

package(
    default_visibility = ["//visibility:public"],
)

objc_library(
    name = "InflectorKit",
    srcs = glob([
        "InflectorKit/*.m",
    ]),
    hdrs = glob([
        "InflectorKit/include/*.h",
    ]),
    includes = [
        "InflectorKit/include",
    ],
    module_name = "InflectorKit",
    deps = [
    ],
)
