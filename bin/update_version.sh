#!/bin/bash

./bin/update_dockle.sh
./bin/update_trivy.sh

if [ "$(git status -s Dockerfile)" ]; then
  git config user.email "$GIT_USER_EMAIL"
  git config user.name "$GIT_USER_NAME"

  git add Dockerfile
  git commit -m "update: tool version"

  curl https://raw.githubusercontent.com/getto-systems/version-dump/master/bin/version_dump.sh | bash
  ./bin/push_tags.sh
fi
