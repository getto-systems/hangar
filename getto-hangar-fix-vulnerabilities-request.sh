#!/bin/sh

set -x

git remote -v

git clone https://github.com/getto-systems/git-pub.git
git clone https://github.com/getto-systems/git-post.git

cwd=$(pwd)
export PATH=$PATH:$cwd/git-pub/bin:$cwd/git-post/bin

if [ -z "$FIX_VULNERABILITIES_MARKER" ]; then
  FIX_VULNERABILITIES_MARKER="to fix vulnerabilities, update packages"
fi

now=$(date --iso-8601)

sed -i \
  -e 's|: "'"$FIX_VULNERABILITIES_MARKER"' : .*"|: "'"$FIX_VULNERABILITIES_MARKER"' : '$now'"|' \
  -e '/: "'"$FIX_VULNERABILITIES_MARKER"'/{n;s|[^:] apt-get|  : apt-get|}' \
  Dockerfile

git config user.email "$GIT_USER_EMAIL"
git config user.name "$GIT_USER_NAME"

git add Dockerfile
git commit -m "fix: vulnerabilities"

super=$(git remote -v | grep "origin.*fetch" | sed 's|.*https|https|' | sed "s|gitlab-ci-token:.*@|$GITLAB_USER:$GITLAB_ACCESS_TOKEN@|" | sed "s| .*||")
branch=fix-vulnerabilities-$(date +%Y%m%d%H%M%S%N)
git push $super HEAD:$branch

export GIT_POST_REMOTE_FORK_NAME=origin
export GITLAB_REMOVE_SOURCE_BRANCH=true

git post "fix: vulnerabilities"
