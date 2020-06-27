#!/usr/bin/env python

import argparse
import subprocess
import os

def main():
  parser = argparse.ArgumentParser(description="Dflat schema compiler")
  parser.add_argument('-o', '--output', dest="output", nargs=1, help="output directory", required=True)
  parser.add_argument('-I', '--include', action='append', dest="include", nargs=1, help="include directory")
  parser.add_argument('files', nargs='+')
  args = parser.parse_args()
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
    dflatc.append(os.path.splitext(fn)[0] + "_generated.json")
  subprocess.call(dflats)
  subprocess.call(dflatc)

if __name__ == "__main__":
  main()
