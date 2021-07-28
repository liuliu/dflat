def _dflatc_impl(ctx):
    for include in ctx.files.includes:
        output = ctx.actions.declare_file("__includes/" + include.basename)
        ctx.actions.symlink(
            output = output,
            target_file = include,
        )
    all_outputs = []
    for src in ctx.files.srcs:
      src_base = ".".join(src.basename.split(".")[:-1])
      json = ctx.actions.declare_file(src_base + "_generated.json")
      flatbuffers = ctx.actions.declare_file(src_base + "_generated.swift")
      ctx.actions.run(
          inputs = [src] + ctx.files.includes,
          outputs = [json, flatbuffers],
          arguments = ["-o", json.dirname, "-I", "__includes", src.path],
          executable = ctx.executable._dflats,
      )
      outputs = [
          ctx.actions.declare_file(src_base + "_data_model_generated.swift"),
          ctx.actions.declare_file(src_base + "_mutating_generated.swift"),
          ctx.actions.declare_file(src_base + "_query_generated.swift"),
      ]
      ctx.actions.run(
          inputs = [json],
          outputs = outputs,
          arguments = ["-o", outputs[0].dirname, json.path],
          executable = ctx.executable._dflatc,
      )
      all_outputs = all_outputs + [flatbuffers] + outputs
    return DefaultInfo(files = depset(all_outputs))

dflatc = rule(
    implementation = _dflatc_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "includes": attr.label_list(allow_files = True),
        "_dflats": attr.label(
            executable = True,
            allow_files = True,
            cfg = "exec",
            default = Label("@dflat//src/parser:dflats"),
        ),
        "_dflatc": attr.label(
            executable = True,
            allow_files = True,
            cfg = "exec",
            default = Label("@dflat//src/parser:dflatc"),
        ),
    },
)

def _dflat_schema_impl(ctx):
    outputs = [
        ctx.actions.declare_file(ctx.attr.root + "_generated.fbs"),
        ctx.actions.declare_file(ctx.attr.root + "_inits_generated.swift"),
    ]
    ctx.actions.run(
        inputs = [ctx.file.schema] + ctx.files.srcs,
        outputs = outputs,
        arguments = [ctx.file.schema.path] + [x.path for x in ctx.files.srcs] + ["--entity", ctx.attr.root, "--primary-key", ctx.attr.primary_key, "-o", outputs[0].dirname],
        executable = ctx.executable._codegen,
    )
    return DefaultInfo(files = depset(outputs))

dflat_schema = rule(
    implementation = _dflat_schema_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "schema": attr.label(allow_single_file = True, mandatory = True),
        "root": attr.string(mandatory = True),
        "primary_key": attr.string(default = "id"),
        "_codegen": attr.label(
            executable = True,
            allow_files = True,
            cfg = "exec",
            default = Label("@dflat//src/graphql:codegen"),
        ),
    },
)
