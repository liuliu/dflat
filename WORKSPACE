workspace(name = "dflat")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

git_repository(
  name = "build_bazel_rules_apple",
  remote = "https://github.com/bazelbuild/rules_apple.git",
  commit = "b5ea324a8aa8d5fd5843a9ad3e663a2d54898fc4",
  shallow_since = "1601006876 -0700"
)

git_repository(
  name = "build_bazel_rules_swift",
  remote = "https://github.com/bazelbuild/rules_swift.git",
  commit = "b7a269355fc9852a885c5becbdeb1497cf787164",
  shallow_since = "1600724082 -0700"
)

git_repository(
  name = "build_bazel_apple_support",
  remote = "https://github.com/bazelbuild/apple_support.git",
  commit = "2583fa0bfd6909e7936da5b30e3547ba13e198dc",
  shallow_since = "1600371270 -0700"
)

git_repository(
  name = "bazel_skylib",
  remote = "https://github.com/bazelbuild/bazel-skylib.git",
  commit = "528e4241345536c487cca8b11db138104bb3bd68",
  shallow_since = "1601067301 +0200"
)

new_git_repository(
  name = "flatbuffers",
  remote = "https://github.com/google/flatbuffers.git",
  commit = "0bdf2fa156f5133b09ddac7beb326b942d524b38",
  shallow_since = "1601319419 -0700",
  build_file = "flatbuffers.BUILD"
)

new_git_repository(
  name = "swift-atomics",
  remote = "https://github.com/apple/swift-atomics.git",
  commit = "d07c2a5c922307b5a24ee45aab6a922b9ebaee33",
  shallow_since = "1601602457 -0700",
  build_file = "swift-atomics.BUILD"
)

load(
  "@build_bazel_rules_swift//swift:repositories.bzl",
  "swift_rules_dependencies"
)

swift_rules_dependencies()

load(
  "@build_bazel_apple_support//lib:repositories.bzl",
  "apple_support_dependencies"
)

apple_support_dependencies()

load(
  "@com_google_protobuf//:protobuf_deps.bzl",
  "protobuf_deps"
)

protobuf_deps()

http_file(
  name = "xctestrunner",
  executable = 1,
  sha256 = "298846d5ad7607eba33e786149c2b642ffe39508d4a99468a8280871d902fe5d",
  urls = ["https://github.com/google/xctestrunner/releases/download/0.2.14/ios_test_runner.par"],
)
