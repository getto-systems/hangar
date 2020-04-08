#!/bin/bash

set -x

export HOME=$(pwd)

if [ -z "$1" ]; then
  echo "usage: getto-hangar-test-from-file.sh <INPUT-FILE>"
  exit 1
fi

input=$1

if [ -f .getto-hangar-trivy-opts ]; then
  trivy_opts="$(cat .getto-hangar-trivy-opts)"
else
  trivy_opts=
fi

dockle --exit-code 1 --input $input &&
trivy --exit-code 1 --quiet --light --no-progress $trivy_opts --input $input &&
:
