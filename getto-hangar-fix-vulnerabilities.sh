#!/bin/sh

set -x

if [ -z "$FIX_VULNERABILITIES_MARKER" ]; then
  FIX_VULNERABILITIES_MARKER="to fix vulnerabilities, update packages"
fi

sed -i \
  -e 's|: "'"$FIX_VULNERABILITIES_MARKER"' : .*"|: "'"$FIX_VULNERABILITIES_MARKER"' : '$(date --iso-8601)'"|' \
  -e '/: "'"$FIX_VULNERABILITIES_MARKER"'/{n;s|[^:] apt-get|  : apt-get|}' \
  Dockerfile

git add Dockerfile
git commit -m "fix: vulnerabilities"
