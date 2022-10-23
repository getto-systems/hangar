#!/bin/sh

target=$1

mkdir -p $target

if [ ! -d $target ]; then
  echo "cannot create target directory: $target"
  exit 1
fi

VERSION=0.4.7

tmp=$target/dockle.tmp

mkdir $tmp &&
curl -L -o $tmp/dockle.tar.gz https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.tar.gz &&
tar -zx -f $tmp/dockle.tar.gz -C $tmp &&
mv $tmp/dockle $target &&
rm -rf $tmp &&
:

