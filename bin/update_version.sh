#!/bin/bash

./bin/update_dockle.sh
./bin/update_trivy.sh

if [ "$(git status -s Dockerfile)" ]; then
  git config user.email "$GIT_USER_EMAIL"
  git config user.name "$GIT_USER_NAME"

  git add Dockerfile
  git commit -m "update: tool version"

  echo "update: tool version : $(date --iso-8601=ns)" | ./version-dump/bin/request.sh
fi
