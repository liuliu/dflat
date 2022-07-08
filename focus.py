#!/usr/bin/env python3

import argparse
import subprocess
import os

def main():
  parser = argparse.ArgumentParser(description="Bazel + Tulsi")
  parser.add_argument('target', nargs=1)
  args = parser.parse_args()
  args.target = args.target[0]
  target = args.target.split(":")
  if len(target) < 2:
    print("WARNING: {} doesn't specify the target".format(args.target))
    exit()
  path = target[0]
  name = target[1]
  wsroot = os.path.dirname(__file__)
  if len(wsroot) == 0:
    wsroot = "."
  path = os.path.abspath(path)
  wsroot = os.path.abspath(wsroot)
  path = os.path.relpath(path, wsroot)
  os.chdir(wsroot)
  print("Focus {}:{} ...".format(path, name))
  bazelpath = subprocess.check_output(["which", "bazel"]).strip()
  sourceDirs = "app src"
  tulsigen = ["./generate_xcodeproj.sh", "--create-tulsiproj", name, "--target", path + ":" + name, "--bazel", bazelpath, "--outputfolder", path, "--workspaceroot", ".", "--additionalSourceFilters", sourceDirs, "--build-options", "--strategy=ObjcLink=standalone"]
  genconfig = ["./generate_xcodeproj.sh", "--genconfig", path + "/" + name + ".tulsiproj" + ":" + name]
  subprocess.call(tulsigen)
  subprocess.call(genconfig)

if __name__ == "__main__":
  main()
