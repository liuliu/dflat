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

DflatSchemaInfo = provider(
    "Info to split flatbuffers file and Swift file.",
    fields = {
        "schema": "The flatbuffers schema file.",
        "swift": "The Swift files."
    }
)

def _dflat_schema_impl(ctx):
    flatbuffers = ctx.actions.declare_file(ctx.attr.root + "_generated.fbs")
    swift = ctx.actions.declare_file(ctx.attr.root + "_inits_generated.swift")
    outputs = [flatbuffers, swift]
    primary_key_args = []
    if len(ctx.attr.primary_key) > 0:
        primary_key_args = ["--primary-key", ctx.attr.primary_key]
    ctx.actions.run(
        inputs = [ctx.file.schema] + ctx.files.srcs,
        outputs = outputs,
        arguments = [ctx.file.schema.path] + [x.path for x in ctx.files.srcs] + ["--entity", ctx.attr.root] + primary_key_args + ["--primary-key-type", ctx.attr.primary_key_type, "-o", outputs[0].dirname],
        executable = ctx.executable._codegen,
    )
    return [
        DefaultInfo(files = depset(outputs)),
        DflatSchemaInfo(schema = depset([flatbuffers]), swift = depset([swift]))
    ]

_dflat_schema = rule(
    implementation = _dflat_schema_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "schema": attr.label(allow_single_file = True, mandatory = True),
        "root": attr.string(mandatory = True),
        "primary_key": attr.string(default = ""),
        "primary_key_type": attr.string(default = "String"),
        "_codegen": attr.label(
            executable = True,
            allow_files = True,
            cfg = "exec",
            default = Label("@dflat//src/graphql:codegen"),
        ),
    },
)

def _dflat_schema_flatbuffers_impl(ctx):
    return DefaultInfo(files = ctx.attr.schema[DflatSchemaInfo].schema)

_dflat_schema_flatbuffers = rule(
    implementation = _dflat_schema_flatbuffers_impl,
    attrs = {
        "schema": attr.label(mandatory = True),
    }
)

def _dflat_schema_swift_impl(ctx):
    return DefaultInfo(files = ctx.attr.schema[DflatSchemaInfo].swift)

_dflat_schema_swift = rule(
    implementation = _dflat_schema_swift_impl,
    attrs = {
        "schema": attr.label(mandatory = True),
    }
)

def dflat_graphql(name, srcs, schema, root, primary_key = "", primary_key_type = "String", visibility=None):
    _dflat_schema(
        name = name + "_graphql",
        srcs = srcs,
        schema = schema,
        root = root,
        primary_key = primary_key,
        primary_key_type = primary_key_type,
        visibility = visibility
    )
    _dflat_schema_flatbuffers(name = name + "_graphql_flatbuffers", schema = ":" + name + "_graphql")
    _dflat_schema_swift(name = name + "_graphql_swift", schema = ":" + name + "_graphql")
    dflatc(name = name + "_graphql_dflatc", srcs = [":" + name + "_graphql_flatbuffers"])
    native.filegroup(name = name, srcs = [":" + name + "_graphql_dflatc", ":" + name + "_graphql_swift"], visibility=visibility)
