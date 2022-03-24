workspace(name = "dflat")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

git_repository(
    name = "build_bazel_rules_apple",
    commit = "7115f0188d141d57d64a6875735847c975956dae",
    remote = "https://github.com/bazelbuild/rules_apple.git",
    shallow_since = "1648060786 -0700",
)

new_git_repository(
    name = "flatbuffers",
    build_file = "flatbuffers.BUILD",
    commit = "354d97f6da18cbbdeddfcdd2d5aebf1bcc57a092",
    remote = "https://github.com/google/flatbuffers.git",
    shallow_since = "1632261689 -0700",
)

new_git_repository(
    name = "swift-atomics",
    build_file = "swift-atomics.BUILD",
    commit = "2eb6b8d3ce4e18a9ad10caff4e9c9b99b9ab4899",
    remote = "https://github.com/apple/swift-atomics.git",
    shallow_since = "1631646447 -0700",
)

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:extras.bzl",
    "swift_rules_extra_dependencies",
)

swift_rules_extra_dependencies()

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

http_archive(
    name = "sqlite3",
    build_file = "sqlite3.BUILD",
    sha256 = "999826fe4c871f18919fdb8ed7ec9dd8217180854dd1fe21eea96aed36186729",
    urls = ["https://www.sqlite.org/2021/sqlite-amalgamation-3360000.zip"],
)

# Optional dependencies for Apollo GraphQL support

new_git_repository(
    name = "apollo-ios",
    build_file = "apollo-ios.BUILD",
    commit = "b17ae4cef6e78d60913b33b821ff6ec32ce38c38",
    remote = "https://github.com/apollographql/apollo-ios.git",
    shallow_since = "1625073576 -0700"
)

new_git_repository(
    name = "PathKit",
    build_file = "PathKit.BUILD",
    commit = "c8f12353bca8c252713fd2e2fbc5789c39ff92f8",
    remote = "https://github.com/kylef/PathKit.git",
    shallow_since = "1581802267 +0100"
)

new_git_repository(
    name = "Stencil",
    build_file = "Stencil.BUILD",
    commit = "fd107355c20110d3707ebc2b09aed6b92f3cff7c",
    remote = "https://github.com/stencilproject/Stencil.git",
    shallow_since = "1612728587 +0100"
)

new_git_repository(
    name = "InflectorKit",
    build_file = "InflectorKit.BUILD",
    commit = "e28108ca05b3acb58990b0c05fb7ec57ba6e80bb",
    remote = "https://github.com/mattt/InflectorKit.git",
    shallow_since = "1607017920 -0800"
)

http_archive(
    name = "apollo_cli",
    build_file = "apollo_cli.BUILD",
    sha256 = "496b4de6a4a1f5a1c4a093c8d2378054ebf0dc19361a7dad847f82feeccad2be",
    type = "tar.gz",
    urls = ["https://install.apollographql.com/legacy-cli/darwin/2.33.6"],
)

# Internal tools

new_git_repository(
    name = "SwiftArgumentParser",
    build_file = "swift-argument-parser.BUILD",
    commit = "82905286cc3f0fa8adc4674bf49437cab65a8373",
    remote = "https://github.com/apple/swift-argument-parser.git",
    shallow_since = "1647436700 -0500",
)

new_git_repository(
    name = "SwiftSystem",
    build_file = "swift-system.BUILD",
    commit = "836bc4557b74fe6d2660218d56e3ce96aff76574",
    remote = "https://github.com/apple/swift-system.git",
    shallow_since = "1638472952 -0800",
)

new_git_repository(
    name = "SwiftToolsSupportCore",
    build_file = "swift-tools-support-core.BUILD",
    commit = "b7667f3e266af621e5cc9c77e74cacd8e8c00cb4",
    remote = "https://github.com/apple/swift-tools-support-core.git",
    shallow_since = "1643831290 -0800",
)

new_git_repository(
    name = "SwiftSyntax",
    build_file = "swift-syntax.BUILD",
    commit = "0b6c22b97f8e9320bca62e82cdbee601cf37ad3f",
    remote = "https://github.com/apple/swift-syntax.git",
    shallow_since = "1647591231 +0100",
)

new_git_repository(
    name = "SwiftFormat",
    build_file = "swift-format.BUILD",
    commit = "e6b8c60c7671066d229e30efa1e31acf57be412e",
    remote = "https://github.com/apple/swift-format.git",
    shallow_since = "1647972246 -0700",
)

# buildifier is written in Go and hence needs rules_go to be built.
# See https://github.com/bazelbuild/rules_go for the up to date setup instructions.

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "d1ffd055969c8f8d431e2d439813e42326961d0942bdf734d2c95dc30c369566",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.24.5/rules_go-v0.24.5.tar.gz",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.24.5/rules_go-v0.24.5.tar.gz",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

http_archive(
    name = "bazel_gazelle",
    sha256 = "b85f48fa105c4403326e9525ad2b2cc437babaa6e15a3fc0b1dbab0ab064bc7c",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.2/bazel-gazelle-v0.22.2.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.22.2/bazel-gazelle-v0.22.2.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

git_repository(
    name = "com_github_bazelbuild_buildtools",
    commit = "174cbb4ba7d15a3ad029c2e4ee4f30ea4d76edce",
    remote = "https://github.com/bazelbuild/buildtools.git",
    shallow_since = "1607975103 +0100",
)
