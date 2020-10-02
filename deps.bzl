load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")

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
    commit = "0bdf2fa156f5133b09ddac7beb326b942d524b38",
    shallow_since = "1601319419 -0700",
    build_file = "@dflat//:external/flatbuffers.BUILD",
  )

  _maybe(
    new_git_repository,
    name = "swift-atomics",
    remote = "https://github.com/apple/swift-atomics.git",
    commit = "d07c2a5c922307b5a24ee45aab6a922b9ebaee33",
    shallow_since = "1601602457 -0700",
    build_file = "@dflat//:external/swift-atomics.BUILD"
  )
