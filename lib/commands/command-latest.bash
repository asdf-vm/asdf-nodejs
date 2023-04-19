#! /usr/bin/env bash

set -eu -o pipefail

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

list() {
  local only_installed="$1"

  if [ "$only_installed" ]; then
    ASDF_NODEJS_SKIP_NODEBUILD_UPDATE=1 asdf list nodejs "$query" | cut -c3-
  else
    ASDF_NODEJS_SKIP_NODEBUILD_UPDATE=1 asdf list-all nodejs "$query"
  fi
}

sieve_through_versions() {
  local only_installed='' query=''

  while (("$#")); do
    case "$1" in
    --installed)
      only_installed=1
      ;;
    *)
      query="$1"
      ;;
    esac

    shift
  done

  list "$only_installed" | grep "^$query" | tail -n1
}

sieve_through_versions "$@"
