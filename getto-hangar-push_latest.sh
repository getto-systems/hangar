#!/bin/bash

image=$1

if [ -z "$image" ]; then
  echo "image not specified"
  exit 1
fi

if [ -z "$tag" ]; then
  echo "tag not specified"
  exit 1
fi

if [ -z "$(echo "$tag" | grep '^[0-9.-]\+$')" ]; then
  echo "ignore tag: $tag"
  exit 0
fi

echo "target: $image:$tag"

docker pull $image:$tag > /dev/null
if [ $? == 0 ]; then
  echo "signed image already pushed"
  exit 0
fi

docker pull --disable-content-trust $image:$tag > /dev/null
if [ $? != 0 ]; then
  echo "build not finished"
  exit 0
fi

export HOME=$(pwd)

key_root=$HOME/.docker/trust/private

mkdir -p $key_root

cat $DOCKER_CONTENT_TRUST_ROOT_KEY > $key_root/$DOCKER_CONTENT_TRUST_ROOT_ID.key
cat $DOCKER_CONTENT_TRUST_REPOSITORY_KEY > $key_root/$DOCKER_CONTENT_TRUST_REPOSITORY_ID.key

chmod 600 $key_root/*.key

cat $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin && \
docker tag $image:$tag $image:latest && \
docker push $image:latest && \
docker push $image:$tag && \
:

result=$?

docker logout

if [ $result != 0 ]; then
  exit 1
fi

touch push_latest_success
