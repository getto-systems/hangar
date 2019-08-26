#!/bin/bash

version=$(
  curl --silent "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | \
  grep '"tag_name":' | \
  sed -E 's/.*"v([^"]+)".*/\1/' \
)

sed -i -e "s|TRIVY_VERSION .*|TRIVY_VERSION $version|" Dockerfile
