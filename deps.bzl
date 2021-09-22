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
        commit = "354d97f6da18cbbdeddfcdd2d5aebf1bcc57a092",
        shallow_since = "1632261689 -0700",
        build_file = "@dflat//:external/flatbuffers.BUILD",
    )

    _maybe(
        new_git_repository,
        name = "swift-atomics",
        remote = "https://github.com/apple/swift-atomics.git",
        commit = "2eb6b8d3ce4e18a9ad10caff4e9c9b99b9ab4899",
        shallow_since = "1631646447 -0700",
        build_file = "@dflat//:external/swift-atomics.BUILD",
    )

    _maybe(
        http_archive,
        name = "sqlite3",
        sha256 = "b34f4c0c0eefad9a7e515c030c18702e477f4ef7d8ade6142bdab8011b487ac6",
        urls = ["https://www.sqlite.org/2020/sqlite-amalgamation-3330000.zip"],
        build_file = "@dflat//:external/sqlite3.BUILD",
    )
