load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

git_repository(
  name = "build_bazel_rules_apple",
  remote = "https://github.com/bazelbuild/rules_apple.git",
  commit = "12ac0738c56f8a15c714a7e09ec87a1bbdbcada9",
  shallow_since = "1592940289 -0700"
)

git_repository(
  name = "build_bazel_rules_swift",
  remote = "https://github.com/bazelbuild/rules_swift.git",
  commit = "8ecb09641ee0ba5efd971ffff8dd6cbee6ea7dd3",
  shallow_since = "1584545517 -0700"
)

git_repository(
  name = "build_bazel_apple_support",
  remote = "https://github.com/bazelbuild/apple_support.git",
  commit = "501b4afb27745c4813a88ffa28acd901408014e4",
  shallow_since = "1577729628 -0800"
)

git_repository(
  name = "bazel_skylib",
  remote = "https://github.com/bazelbuild/bazel-skylib.git",
  commit = "d35e8d7bc6ad7a3a53e9a1d2ec8d3a904cc54ff7",
  shallow_since = "1593183852 +0200"
)

new_git_repository(
  name = "flatbuffers",
  remote = "https://github.com/google/flatbuffers.git",
  commit = "e810635eaac4cad6e026522843152e2b501c5889",
  shallow_since = "1593337015 +0300",
  build_file = "flatbuffers.BUILD",
)

new_git_repository(
  name = "swift-atomics",
  remote = "https://github.com/glessard/swift-atomics.git",
  commit = "5353f78a030ab2b5f0468db78b2887d1eec54fe3",
  shallow_since = "1591993436 -0600",
  build_file = "swift-atomics.BUILD",
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
  sha256 = "890faff3f6d5321712ffb7a09ba3614eabca93977221e86d058c7842fdbad6b6",
  urls = ["https://github.com/google/xctestrunner/releases/download/0.2.13/ios_test_runner.par"],
)
