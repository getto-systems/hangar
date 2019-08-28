#!/bin/bash

git tag $(cat .release-version)

super=$(git remote -v | grep "origin.*fetch" | sed 's|.*https|https|' | sed "s|gitlab-ci-token:.*@|$GITLAB_USER:$GITLAB_ACCESS_TOKEN@|" | sed "s| .*||")
git push $super HEAD:master --tags

if [ $? != 0 ]; then
  exit 1
fi

if [ -f .git-maint-repo ]; then
  maint=$(cat .git-maint-repo | sed "s|https://|https://$GITHUB_USER:$GITHUB_ACCESS_TOKEN@|")
  git push $maint HEAD:master --tags
fi
