#!/usr/bin/env bash

set -euo pipefail

GIT_ROOT=$(git rev-parse --show-toplevel)

cd $GIT_ROOT

# Generate symbol graph
bazel build :Dflat :SQLiteDflat --features=swift.emit_symbol_graph
# Copy it into a valid bundle
mkdir -p Dflat.docc
cp bazel-bin/Dflat.symbolgraph/*.json Dflat.docc/
cp bazel-bin/SQLiteDflat.symbolgraph/*.json Dflat.docc/
# Remove all docs
rm -rf docs
# Convert into static hosting document
docc convert Dflat.docc --fallback-display-name="Dflat" --fallback-bundle-identifier org.liuliu.dflat --fallback-bundle-version 0.0.1 --output-path docs --hosting-base-path /dflat --index --transform-for-static-hosting
# Adding auto-redirect index.html
echo '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta http-equiv="refresh" content="0;url=https://liuliu.github.io/dflat/documentation/dflat">' > docs/index.html
rm -rf Dflat.docc
