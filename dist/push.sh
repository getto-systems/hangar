#!/bin/sh

target=$1
image=$2

if [ -z "$target" ]; then
  echo "usage: push.sh <Dockerfile> <image>"
  exit 1
fi

if [ -z "$image" ]; then
  echo "usage: push.sh <Dockerfile> <image>"
  exit 1
fi

docker build -f $target -t $image . &&
docker push $image &&
:
