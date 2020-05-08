#!/bin/bash

version=$(
  curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | \
  grep '"tag_name":' | \
  sed -E 's/.*"v([^"]+)".*/\1/' \
)

file=dist/install_dockle.sh

sed -i -e "s|VERSION .*|VERSION $version|" $file &&
git add $file
