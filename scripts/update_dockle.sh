#!/bin/bash

version=$(
  curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | \
  grep '"tag_name":' | \
  sed -E 's/.*"v([^"]+)".*/\1/' \
)

sed -i -e "s|DOCKLE_VERSION .*|DOCKLE_VERSION $version|" Dockerfile
