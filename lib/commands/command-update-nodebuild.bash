#! /usr/bin/env bash

set -eu -o pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils.sh"

: "${ASDF_NODEJS_NODEBUILD_HOME=$ASDF_NODEJS_PLUGIN_DIR/.node-build}"
: "${ASDF_NODEJS_NODEBUILD_REPOSITORY=https://github.com/nodenv/node-build.git}"

ensure_updated_project() {
  local pull_exit_code=

  if ! [ -d "$ASDF_NODEJS_NODEBUILD_HOME" ]; then
    printf "Cloning node-build...\n"
    git clone "$ASDF_NODEJS_NODEBUILD_REPOSITORY" "$ASDF_NODEJS_NODEBUILD_HOME"
  else
    printf "Trying to update node-build...\n"
    git -C "$ASDF_NODEJS_NODEBUILD_HOME" pull origin master || pull_exit_code=$?

    if [ "$pull_exit_code" ]; then
      printf "ERROR: Updating the node-build repository exited with code %s\n" "$pull_exit_code"
      printf "Please check if the git repository at %s doesn't have any changes or anything that might not allow a git pull\n" "$ASDF_NODEJS_NODEBUILD_REPOSITORY" 
      exit 1
    fi
  fi
}

ensure_updated_project
