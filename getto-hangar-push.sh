#!/bin/bash

export HOME=$(pwd)

hangar_id=$(head -1 .gitlab-ci.yml | cut -d' ' -f2 | sed 's/.*://' | sed 's/-.*//')
image=getto/hangar:$hangar_id-$(date +%Y%m%d%H%M%S)

key_root=$HOME/.docker/trust/private

mkdir -p $key_root

cat $DOCKER_CONTENT_TRUST_ROOT_KEY > $key_root/$DOCKER_CONTENT_TRUST_ROOT_ID.key
cat $DOCKER_CONTENT_TRUST_REPOSITORY_KEY > $key_root/$DOCKER_CONTENT_TRUST_REPOSITORY_ID.key

chmod 600 $key_root/*.key

cat $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin && \
docker build -t $image . && \
docker push $image && \
:

result=$?

docker logout

if [ $result != 0 ]; then
  exit 1
fi


git config user.email "$GIT_USER_EMAIL"
git config user.name "$GIT_USER_NAME"

sed -i -e "s|image: getto/hangar:$hangar_id-.*|image: $image|" .gitlab-ci.yml
git add .gitlab-ci.yml
git commit -m "update: image"

./bin/push_tags.sh
