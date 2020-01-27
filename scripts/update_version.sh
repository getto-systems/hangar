#!/bin/bash

./scripts/update_dockle.sh
./scripts/update_trivy.sh

if [ "$(git status -s Dockerfile)" ]; then
  git add Dockerfile
  git commit -m "update: tool version"

  curl https://trellis.getto.systems/ci/bump-version/1.2.2/request.sh | bash -s -- ./.update-version-message.sh
fi
