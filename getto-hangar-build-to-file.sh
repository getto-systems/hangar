#!/bin/bash

if [ -z "$1" ]; then
  echo 'usage: getto-hangar-build-to-file.sh <OUTPUT-FILE>'
  exit 1
fi

output=$1

set -x

image=getto/hangar:$CI_COMMIT_SHORT_SHA

docker build -t $image .

if [ $? != 0 ]; then
  exit 1
fi

docker image save $image --output $output
