#!/bin/sh

load_trellis_main(){
  local root
  local target
  local alias
  local version
  local path

  root=https://trellis.getto.systems

  target=$1
  alias=$2
  path=$3

  if [ -z "$target" ]; then
    load_trellis_usage
  fi

  if [ -z "$alias" ]; then
    load_trellis_usage
  fi

  if [ -z "$path" ]; then
    load_trellis_usage
  fi

  load_trellis_check_status "$root/$target/alias/$alias"

  version=$(curl -s -o /dev/stdout "$root/$target/alias/$alias")

  load_trellis_check_status "$root/$target/$version/$path"

  curl -s -o /dev/stdout "$root/$target/$version/$path"
}

load_trellis_usage(){
  echo "usage: load_trellis.sh <target> <alias> <path>" >&2
  echo "  example: load_trellis.sh hangar latest install_trivy.sh" >&2
  exit 1
}

load_trellis_check_status(){
  local url
  local status

  url=$1

  status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$status" != 200 ]; then
    echo "not found: $url" >&2
    exit 1
  fi
}

load_trellis_main "$@"
