#!/bin/bash

set -x

export HOME=$(pwd)

if [ -z "$image" ]; then
  if [ -f .getto-hangar-test-image.sh ]; then
    image=$(.getto-hangar-test-image.sh)
  fi

  if [ -z "$image" ]; then
    echo "image not detected"
    exit 1
  fi
fi

if [ -f Dockerfile-test ]; then
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

dockle --exit-code 1 $image && \
trivy --exit-code 1 --quiet --auto-refresh $trivy_opts $image && \
:
