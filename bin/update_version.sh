#!/bin/bash

./bin/update_dockle.sh
./bin/update_trivy.sh

if [ "$(git status -s Dockerfile)" ]; then
  git add Dockerfile
  git commit -m "update: tool version"

  curl https://raw.githubusercontent.com/getto-systems/version-dump/master/bin/version_dump.sh | bash
  ./bin/push_tags.sh
fi
