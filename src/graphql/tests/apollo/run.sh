#!/usr/bin/env bash

RUNFILES=${BASH_SOURCE[0]}.runfiles
"$RUNFILES/apollo_cli/apollo/bin/node" "$RUNFILES/apollo_cli/apollo/bin/run" "$@"
