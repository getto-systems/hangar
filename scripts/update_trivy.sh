#!/bin/bash

version=$(
  curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | \
  grep '"tag_name":' | \
  sed -E 's/.*"v([^"]+)".*/\1/' \
)

file=dist/install_trivy.sh

sed -i -e "s|VERSION=.*|VERSION=$version|" $file &&
git add $file
