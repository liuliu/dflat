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
    "Benchmarks/doc_v2_generated.swift",
    "Benchmarks/doc_v2_data_model_generated.swift",
    "Benchmarks/doc_v2_mutating_generated.swift",
    "Benchmarks/doc_v2_query_generated.swift",
    "Benchmarks/doc_v3_generated.swift",
    "Benchmarks/doc_v3_data_model_generated.swift",
    "Benchmarks/doc_v3_mutating_generated.swift",
    "Benchmarks/doc_v3_query_generated.swift",
    "Benchmarks/doc_v4_generated.swift",
    "Benchmarks/doc_v4_data_model_generated.swift",
    "Benchmarks/doc_v4_mutating_generated.swift",
    "Benchmarks/doc_v4_query_generated.swift",
  ],
	data = glob(["Benchmarks/DataModel.xcdatamodeld/**"]),
  deps = [
    "//:Dflat",
    "//:SQLiteDflat",
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
