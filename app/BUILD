load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
  name = "Benchmarks",
  srcs = [
    "Benchmarks/AppDelegate.swift",
    "Benchmarks/ViewController.swift",
    "Benchmarks/doc_generated.swift",
    "Benchmarks/doc_data_model_generated.swift",
    "Benchmarks/doc_mutating_generated.swift",
    "Benchmarks/doc_query_generated.swift",
  ],
  deps = [
    "//src:Dflat",
    "//src:SQLiteDflat",
  ],
)

ios_application(
  name = "BenchmarksApp",
  bundle_id = "com.liuliu.Benchmarks",
  families = [
    "iphone",
    "ipad",
  ],
  provisioning_profile = "dev.mobileprovision",
  minimum_os_version = "11.0",
  infoplists = [":Benchmarks/Benchmarks-Info.plist"],
  visibility = ["//visibility:public"],
  deps = [":Benchmarks"],
)
