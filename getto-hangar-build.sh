#!/bin/bash

set -x

export HOME=$(pwd)

image=getto/hangar:$CI_COMMIT_SHORT_SHA

docker build -t $image .

if [ $? != 0 ]; then
  exit 1
fi

if [ -f Dockerfile-test ]; then
  sed -i -e "s|FROM.*|FROM $image|" Dockerfile-test

  docker build -t $image-test -f Dockerfile-test --disable-content-trust . && \
  docker run --rm --disable-content-trust $image-test

  if [ $? != 0 ]; then
    exit 1
  fi
fi

dockle --exit-code 1 $image && \
trivy --exit-code 1 --quiet --ignore-unfixed --auto-refresh $image && \
:
