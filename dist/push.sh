#!/bin/bash

export HOME=$(pwd)

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

key_root=$HOME/.docker/trust/private

mkdir -p $key_root

cat $DOCKER_CONTENT_TRUST_ROOT_KEY > $key_root/$DOCKER_CONTENT_TRUST_ROOT_ID.key
cat $DOCKER_CONTENT_TRUST_REPOSITORY_KEY > $key_root/$DOCKER_CONTENT_TRUST_REPOSITORY_ID.key

chmod 600 $key_root/*.key

cat $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin &&
docker build -f $target -t $image . &&
docker push $image &&
:
