load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library", "swift_test")
load("@dflat//:dflat.bzl", "dflat_schema", "dflat_schema_flatbuffers", "dflat_schema_swift", "dflatc")

filegroup(
    name = "GraphQL_Files",
    srcs = glob(["starwars/*.graphql"]),
)

filegroup(
    name = "GraphQL_Schema",
    srcs = ["starwars/schema.json"],
)

genrule(
    name = "StarWarsAPI_Sources",
    srcs = [
        ":GraphQL_Files",
        ":GraphQL_Schema",
    ],
    outs = ["API.swift"],
    # Apollo CLI is not happy to see bunch of symlinked files. So we copied the GraphQL files out
    # such that we can use --includes properly.
    cmd = """
mkdir -p $$(dirname $(location API.swift))/SearchPaths && \
cp $(locations :GraphQL_Files) $$(dirname $(location API.swift))/SearchPaths && \
$(location //src/graphql/tests/apollo:cli) codegen:generate --target=swift --includes=$$(dirname $(location API.swift))/SearchPaths/*.graphql --localSchemaFile=$(location :GraphQL_Schema) $(location API.swift)
""",
    tools = ["//src/graphql/tests/apollo:cli"],
)

dflat_schema(
    name = "Generated_schema",
    srcs = [":GraphQL_Files"],
    root = "Character",
    schema = ":GraphQL_Schema",
)

dflat_schema_flatbuffers(
    name = "Generated_flatbuffers",
    schema = ":Generated_schema",
)

dflat_schema_swift(
    name = "Generated_swift",
    schema = ":Generated_schema",
)

dflatc(
    name = "Character_generated_schema",
    srcs = [":Generated_flatbuffers"],
)

swift_library(
    name = "Tests_lib",
    srcs = [
        "GraphQLTests.swift",
        "main.swift",
        ":Character_generated_schema",
        ":Generated_swift",
        ":StarWarsAPI_Sources",
    ],
    deps = [
        "//:SQLiteDflat",
        "@apollo-ios//:Apollo",
    ],
)

swift_test(
    name = "Tests",
    deps = [
        ":Tests_lib",
    ],
)

ios_unit_test(
    name = "iOSTests",
    minimum_os_version = "11.0",
    deps = [
        ":Tests_lib",
    ],
)
