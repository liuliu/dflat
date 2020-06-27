load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

git_repository(
  name = "build_bazel_rules_apple",
  remote = "https://github.com/bazelbuild/rules_apple.git",
  commit = "19f031f09185e0fcd722c22e596d09bd6fff7944",
  shallow_since = "1570721035 -0700",
  # tag = "0.19.0",
)

git_repository(
  name = "build_bazel_rules_swift",
  remote = "https://github.com/bazelbuild/rules_swift.git",
  commit = "ebef63d4fd639785e995b9a2b20622ece100286a",
  shallow_since = "1570649187 -0700",
  # tag = "0.13.0",
)

git_repository(
  name = "build_bazel_apple_support",
  remote = "https://github.com/bazelbuild/apple_support.git",
  commit = "8c585c66c29b9d528e5fcf78da8057a6f3a4f001",
  shallow_since = "1570646613 -0700",
  # tag = "0.7.2",
)

git_repository(
  name = "bazel_skylib",
  remote = "https://github.com/bazelbuild/bazel-skylib.git",
  commit = "e59b620b392a8ebbcf25879fc3fde52b4dc77535",
  shallow_since = "1570639401 -0400",
  # tag = "1.0.2",
)

new_git_repository(
  name = "flatbuffers",
  remote = "https://github.com/liuliu/flatbuffers.git",
  commit = "f4b91a02ecfa4cae97bbf72cdeb92446f3e716e2",
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
