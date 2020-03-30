#!/bin/bash

set -x

export HOME=$(pwd)

if [ -z "$image" ]; then
  if [ -f .getto-hangar-image ]; then
    image=$(cat .getto-hangar-image)
  else
    if [ -x .getto-hangar-test-image.sh ]; then
      image=$(./.getto-hangar-test-image.sh)
    fi
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

if [ ! -f .getto-hangar-skip-dockle ]; then
  dockle --exit-code 1 $image
  if [ $? != 0 ]; then
    exit 1
  fi
fi

trivy --exit-code 1 --quiet --light --no-progress $trivy_opts $image
