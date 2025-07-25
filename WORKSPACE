workspace(name = "dflat")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

git_repository(
    name = "build_bazel_rules_swift",
    commit = "bffd22a56b8949616dfbd710cdca385cb2800274",
    remote = "https://github.com/bazelbuild/rules_swift.git",
    shallow_since = "1752542865 -0400",
)

git_repository(
    name = "build_bazel_rules_apple",
    commit = "724e402ee9f270b6704737251d785ad405661ab0",
    remote = "https://github.com/bazelbuild/rules_apple.git",
    shallow_since = "1753131380 +0000",
)

new_git_repository(
    name = "flatbuffers",
    build_file = "flatbuffers.BUILD",
    commit = "c92e78a9f841a6110ec27180d68d1f7f2afda21d",
    remote = "https://github.com/google/flatbuffers.git",
    shallow_since = "1664514727 -0700",
)

new_git_repository(
    name = "swift-atomics",
    build_file = "swift-atomics.BUILD",
    commit = "088df27f0683f2b458021ebf04873174b91ae597",
    remote = "https://github.com/apple/swift-atomics.git",
    shallow_since = "1649274362 -0700",
)

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies(ignore_version_differences = True)

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
    sha256 = "9ad6d16cbc1df7cd55c8b55127c82a9bca5e9f287818de6dc87e04e73599d754",
    urls = ["https://www.sqlite.org/2025/sqlite-amalgamation-3500300.zip"],
)

# Optional dependencies for Apollo GraphQL support

new_git_repository(
    name = "apollo-ios",
    build_file = "apollo-ios.BUILD",
    commit = "51c81bd69c8c2ab8f28c01a413f15b503d2a4a44",
    remote = "https://github.com/apollographql/apollo-ios.git",
    shallow_since = "1654723347 -0700",
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
    commit = "04d4497be6b88e524a71778d828790e9589ae1c4",
    remote = "https://github.com/apple/swift-syntax.git",
    shallow_since = "1663670179 +0200",
)

new_git_repository(
    name = "SwiftFormat",
    build_file = "swift-format.BUILD",
    commit = "5f184220d032a019a63df457cdea4b9c8241e911",
    remote = "https://github.com/apple/swift-format.git",
    shallow_since = "1665415355 -0700",
)

http_archive(
    name = "rules_python",
    sha256 = "fa532d635f29c038a64c8062724af700c30cf6b31174dd4fac120bc561a1a560",
    strip_prefix = "rules_python-1.5.1",
    url = "https://github.com/bazel-contrib/rules_python/releases/download/1.5.1/rules_python-1.5.1.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# buildifier is written in Go and hence needs rules_go to be built.
# See https://github.com/bazelbuild/rules_go for the up to date setup instructions.
http_archive(
    name = "io_bazel_rules_go",
    sha256 = "6dc2da7ab4cf5d7bfc7c949776b1b7c733f05e56edc4bcd9022bb249d2e2a996",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.39.1/rules_go-v0.39.1.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.39.1/rules_go-v0.39.1.zip",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_rules_dependencies")

go_rules_dependencies()

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains")

go_register_toolchains(version = "1.20.3")

http_archive(
    name = "bazel_gazelle",
    sha256 = "727f3e4edd96ea20c29e8c2ca9e8d2af724d8c7778e7923a854b2c80952bc405",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.30.0/bazel-gazelle-v0.30.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.30.0/bazel-gazelle-v0.30.0.tar.gz",
    ],
)

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

# If you use WORKSPACE.bazel, use the following line instead of the bare gazelle_dependencies():
# gazelle_dependencies(go_repository_default_config = "@//:WORKSPACE.bazel")
gazelle_dependencies()

http_archive(
    name = "com_google_protobuf",
    sha256 = "3bd7828aa5af4b13b99c191e8b1e884ebfa9ad371b0ce264605d347f135d2568",
    strip_prefix = "protobuf-3.19.4",
    urls = [
        "https://github.com/protocolbuffers/protobuf/archive/v3.19.4.tar.gz",
    ],
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "ae34c344514e08c23e90da0e2d6cb700fcd28e80c02e23e4d5715dddcb42f7b3",
    strip_prefix = "buildtools-4.2.2",
    urls = [
        "https://github.com/bazelbuild/buildtools/archive/refs/tags/4.2.2.tar.gz",
    ],
)
