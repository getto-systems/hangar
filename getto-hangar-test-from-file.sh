#!/bin/bash

set -x

export HOME=$(pwd)

if [ -z "$1" ]; then
  echo "usage: getto-hangar-test-from-file.sh <INPUT-FILE>"
  exit 1
fi

input=$1

if [ -f Dockerfile-test ]; then
  image=$(docker image load --input $input)
  image=${image#Loaded image: }

  sed -i -e "s|FROM.*|FROM $image|" Dockerfile-test

  docker build -t $image-test -f Dockerfile-test --disable-content-trust . && \
  docker run --rm --disable-content-trust $image-test

  if [ $? != 0 ]; then
    exit 1
  fi
fi

if [ -f .getto-hangar-trivy-opts ]; then
  trivy_opts="$(cat .getto-hangar-trivy-opts)"
else
  trivy_opts=
fi

dockle --exit-code 1 --input $input &&
trivy --exit-code 1 --quiet --light --no-progress $trivy_opts --input $input &&
:
