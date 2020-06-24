load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

git_repository(
  name = "build_bazel_rules_apple",
  remote = "https://github.com/bazelbuild/rules_apple.git",
  tag = "0.19.0",
)

git_repository(
  name = "build_bazel_rules_swift",
  remote = "https://github.com/bazelbuild/rules_swift.git",
  tag = "0.13.0",
)

git_repository(
  name = "build_bazel_apple_support",
  remote = "https://github.com/bazelbuild/apple_support.git",
  tag = "0.7.2",
)

git_repository(
  name = "bazel_skylib",
  remote = "https://github.com/bazelbuild/bazel-skylib.git",
  tag = "0.9.0",
)

new_git_repository(
  name = "flatbuffers",
  remote = "https://github.com/google/flatbuffers.git",
  commit = "14baf45c90a076d405e75cfc41874ffff862fb72",
  build_file = "flatbuffers.BUILD",
)

load(
  "@build_bazel_rules_swift//swift:repositories.bzl",
  "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
  "@build_bazel_apple_support//lib:repositories.bzl",
  "apple_support_dependencies",
)

apple_support_dependencies()

load(
  "@com_google_protobuf//:protobuf_deps.bzl",
  "protobuf_deps",
)

protobuf_deps()

http_file(
  name = "xctestrunner",
  executable = 1,
  sha256 = "8b7352f7414de4b54478563c90d55509030baa531696dfe9c4e1bf0617ee5eb0",
  urls = ["https://github.com/google/xctestrunner/releases/download/0.2.12/ios_test_runner.par"],
)
