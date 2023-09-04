#!/bin/sh

target=$1

mkdir -p $target

if [ ! -d $target ]; then
  echo "cannot create target directory: $target"
  exit 1
fi

VERSION=0.45.0

tmp=$target/trivy.tmp

mkdir $tmp &&
curl -L -o $tmp/trivy.tar.gz https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz &&
tar -zx -f $tmp/trivy.tar.gz -C $tmp &&
mv $tmp/trivy $target &&
rm -rf $tmp &&
:
