#!/bin/bash

./bin/update_dockle.sh
./bin/update_trivy.sh

if [ "$(git status -s Dockerfile)" ]; then
  git clone https://github.com/getto-systems/git-pub.git
  git clone https://github.com/getto-systems/git-post.git

  cwd=$(pwd)
  export PATH=$PATH:$cwd/git-pub/bin:$cwd/git-post/bin

  git config user.email "$GIT_USER_EMAIL"
  git config user.name "$GIT_USER_NAME"

  branch=update-tool-version-$(date +%Y%m%d%H%M%S%N)
  git checkout -b $branch

  git add Dockerfile

  message="update: tool version"
  git commit -m "$message"

  super=$(git remote -v | grep "origin.*fetch" | sed 's|.*https|https|' | sed "s|gitlab-ci-token:.*@|$GITLAB_USER:$GITLAB_ACCESS_TOKEN@|" | sed "s| .*||")
  git push $super $branch:$branch

  export GIT_POST_REMOTE_FORK_NAME=origin
  export GITLAB_REMOVE_SOURCE_BRANCH=true

  git post "$message"
fi
