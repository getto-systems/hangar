#!/bin/sh

set -x

target=$1

if [ -z "$target" ]; then
  echo "usage: fix-vulnerabilities.sh <Dockerfile>"
  exit 1
fi

if [ -z "$FIX_VULNERABILITIES_MARKER" ]; then
  FIX_VULNERABILITIES_MARKER="to fix vulnerabilities, update packages"
fi

sed -i \
  -e 's|: "'"$FIX_VULNERABILITIES_MARKER"' : .*"|: "'"$FIX_VULNERABILITIES_MARKER"' : '$(date --iso-8601)'"|' \
  -e '/: "'"$FIX_VULNERABILITIES_MARKER"'/{n;s|[^:] \(apt-get\|dnf\)|  : \1|}' \
  $target
