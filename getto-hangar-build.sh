#!/bin/bash

set -x

image=getto/hangar:$CI_COMMIT_SHORT_SHA

docker build -t $image .

if [ $? != 0 ]; then
  exit 1
fi

. getto-hangar-test.sh
