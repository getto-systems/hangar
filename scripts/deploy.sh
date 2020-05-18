#!/bin/bash

deploy_main(){
  local version
  local domain

  version=$(cat .release-version)
  domain=trellis.getto.systems/hangar

  deploy_to $domain
  deploy_check $domain install_trivy.sh
}
deploy_to(){
  local target
  target=$1; shift

  aws s3 cp \
    --acl private \
    --cache-control "public, max-age=31536000" \
    --recursive \
    dist s3://$target/$version

  aws s3 cp \
    --acl private \
    --cache-control "public, max-age=300" \
    --recursive \
    alias s3://$target/alias
}
deploy_check(){
  local target
  local file
  local retry_limit
  local status

  target=$1; shift
  file=$1; shift

  retry_limit=10
  sleep 1

  while [ true ]; do
    status=$(curl -sI https://$target/$version/$file | head -1)

    if [ -n "$(echo $status | grep 200)" ]; then
      echo $status
      return
    fi

    if [ $retry_limit -gt 0 ]; then
      retry_limit=$((retry_limit - 1))
      sleep 1
    else
      echo $status
      exit 1
    fi
  done
}

deploy_main
