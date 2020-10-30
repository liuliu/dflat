def _dflatc_impl(ctx):
  for include in ctx.files.includes:
    output = ctx.actions.declare_file("__includes/" + include.basename)
    ctx.actions.symlink(
      output = output,
      target_file = include
    )
  src_base = ".".join(ctx.file.src.basename.split(".")[:-1])
  json = ctx.actions.declare_file(src_base + "_generated.json")
  flatbuffers = ctx.actions.declare_file(src_base + "_generated.swift")
  ctx.actions.run(
    inputs = [ctx.file.src] + ctx.files.includes,
    outputs = [json, flatbuffers],
    arguments = ["-o", json.dirname, "-I", "__includes", ctx.file.src.path],
    executable = ctx.executable._dflats
  )
  outputs = [
    ctx.actions.declare_file(src_base + "_data_model_generated.swift"),
    ctx.actions.declare_file(src_base + "_mutating_generated.swift"),
    ctx.actions.declare_file(src_base + "_query_generated.swift")
  ]
  ctx.actions.run(
    inputs = [json],
    outputs = outputs,
    arguments = ["-o", outputs[0].dirname, json.path],
    executable = ctx.executable._dflatc
  )
  return DefaultInfo(files = depset([flatbuffers] + outputs))

dflatc = rule(
  implementation = _dflatc_impl,
  attrs = {
    "src": attr.label(allow_single_file = True, mandatory = True),
    "includes": attr.label_list(allow_files = True),
    "_dflats": attr.label(
      executable = True,
      allow_files = True,
      cfg = "exec",
      default = Label("@dflat//src/parser:dflats")
    ),
    "_dflatc": attr.label(
      executable = True,
      allow_files = True,
      cfg = "exec",
      default = Label("@dflat//src/parser:dflatc")
    )
  }
)
