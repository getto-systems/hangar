#!/bin/sh

set -x

git clone https://github.com/getto-systems/version-dump.git

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

echo "fix: vulnerabilities : $(date --iso-8601=ns)" | ./version-dump/request.sh
