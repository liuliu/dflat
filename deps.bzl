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
    commit = "a0fb30575c2425512ebc2757910d106e15114b58",
    shallow_since = "1596179265 +0300",
    build_file = "@dflat//:external/flatbuffers.BUILD",
  )

  _maybe(
    new_git_repository,
    name = "swift-atomics",
    remote = "https://github.com/glessard/swift-atomics.git",
    commit = "5353f78a030ab2b5f0468db78b2887d1eec54fe3",
    shallow_since = "1591993436 -0600",
    build_file = "@dflat//:external/swift-atomics.BUILD"
  )
