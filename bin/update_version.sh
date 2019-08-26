#!/bin/bash

./bin/update_dockle.sh
./bin/update_trivy.sh

if [ "$(git status -s Dockerfile)" ]; then
  git add Dockerfile
  git commit -m "update: tool version"

  ./bin/push_tags.sh
fi
