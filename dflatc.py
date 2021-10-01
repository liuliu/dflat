#!/usr/bin/env python

import argparse
import subprocess
import os

def compile(args):
  if args.include is not None:
    for i in range(len(args.include)):
      args.include[i] = os.path.abspath(args.include[i][0])
  args.output = os.path.abspath(args.output[0])
  for i in range(len(args.files)):
    args.files[i] = os.path.abspath(args.files[i])
  wsroot = os.path.dirname(__file__)
  if len(wsroot) == 0:
    wsroot = "."
  os.chdir(wsroot)
  dflats = ["bazel", "run", "src/parser:dflats", "--", "-o", args.output]
  if args.include is not None:
    for include in args.include:
      dflats += ["-I", args.include[i]]
  dflats += args.files
  dflatc = ["bazel", "run", "src/parser:dflatc", "--", "-o", args.output]
  for fn in args.files:
    dflatc.append(args.output + "/" + os.path.basename(os.path.splitext(fn)[0]) + "_generated.json")
  subprocess.call(dflats)
  subprocess.call(dflatc)
  if not args.keep_json:
    for fn in args.files:
      os.remove(args.output + "/" + os.path.basename(os.path.splitext(fn)[0]) + "_generated.json")


def graphql(args):
  args.output = os.path.abspath(args.output[0])
  args.schema = os.path.abspath(args.schema[0])
  args.entity = args.entity[0]
  for i in range(len(args.files)):
    args.files[i] = os.path.abspath(args.files[i])
  wsroot = os.path.dirname(__file__)
  if len(wsroot) == 0:
    wsroot = "."
  graphql = ["bazel", "run", "src/graphql:codegen", "--", args.schema]
  graphql += args.files
  graphql += ["-o", args.output, "--entity", args.entity]
  if args.primary_key is not None:
    args.primary_key = args.primary_key[0]
    graphql += ["--primary-key", args.primary_key]
  if args.primary_key_type is not None:
    args.primary_key_type = args.primary_key_type[0]
    graphql += ["--primary-key-type", args.primary_key_type]
  subprocess.call(graphql)


def main():
  parser = argparse.ArgumentParser(description="Dflat schema compiler")
  subparsers = parser.add_subparsers(title='subcommands')
  compile_parser = subparsers.add_parser('compile', help='Compile flatbuffers schema into Dflat source code')
  compile_parser.add_argument('-o', '--output', dest="output", nargs=1, help="output directory", required=True)
  compile_parser.add_argument('--keep-json', action='store_true', help="keep the intermediate json file")
  compile_parser.add_argument('-I', '--include', action='append', dest="include", nargs=1, help="include directory")
  compile_parser.add_argument('files', nargs='+')
  compile_parser.set_defaults(func=compile)
  graphql_parser = subparsers.add_parser('graphql', help='Apollo GraphQL based flatbuffers schema and initializers')
  graphql_parser.add_argument('-o', '--output', dest="output", nargs=1, help="output directory", required=True)
  graphql_parser.add_argument('-S', '--schema', dest="schema", nargs=1, help="schema file", required=True)
  graphql_parser.add_argument('--entity', dest="entity", nargs=1, help="entity name", required=True)
  graphql_parser.add_argument('--primary-key', dest="primary_key", nargs=1, help="primary key, if left unspecified, the entity won't be the root_type.")
  graphql_parser.add_argument('--primary-key-type', dest="primary_key_type", nargs=1, help="The type of the primary key, if left unspecified, the default will be String. One of {Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float, Double, String}")
  graphql_parser.add_argument('files', nargs='+')
  graphql_parser.set_defaults(func=graphql)
  args = parser.parse_args()
  args.func(args)


if __name__ == "__main__":
  main()
