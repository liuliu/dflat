load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _maybe(repo_rule, name, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.
    Args:
      repo_rule: The repository rule to be executed (e.g., `http_archive`.)
      name: The name of the repository to be defined by the rule.
      **kwargs: Additional arguments passed directly to the repository rule.
    """
    if not native.existing_rule(name):
        repo_rule(name = name, **kwargs)

def dflat_deps():
    """Loads common dependencies needed to compile the dflat library."""

    _maybe(
        new_git_repository,
        name = "flatbuffers",
        remote = "https://github.com/google/flatbuffers.git",
        commit = "c92e78a9f841a6110ec27180d68d1f7f2afda21d",
        shallow_since = "1664514727 -0700",
        build_file = "@dflat//:external/flatbuffers.BUILD",
    )

    _maybe(
        new_git_repository,
        name = "swift-atomics",
        remote = "https://github.com/apple/swift-atomics.git",
        commit = "088df27f0683f2b458021ebf04873174b91ae597",
        shallow_since = "1649274362 -0700",
        build_file = "@dflat//:external/swift-atomics.BUILD",
    )

    _maybe(
        http_archive,
        name = "sqlite3",
        sha256 = "9da21e6b14ef6a943cdc30f973df259fb390bb4483f77e7f171b9b6e977e5458",
        urls = ["https://www.sqlite.org/2024/sqlite-amalgamation-3470100.zip"],
        build_file = "@dflat//:external/sqlite3.BUILD",
    )
