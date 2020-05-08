#!/bin/sh

export HOME=$(pwd)

key_root=$HOME/.docker/trust/private

mkdir -p $key_root

cat $DOCKER_CONTENT_TRUST_ROOT_KEY > $key_root/$DOCKER_CONTENT_TRUST_ROOT_ID.key
cat $DOCKER_CONTENT_TRUST_REPOSITORY_KEY > $key_root/$DOCKER_CONTENT_TRUST_REPOSITORY_ID.key

chmod 600 $key_root/*.key

cat $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin
