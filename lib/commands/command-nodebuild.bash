#! /usr/bin/env bash

set -eu -o pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils.sh"

# Use a local variable for concurrency calculation
local_concurrency="${ASDF_CONCURRENCY}"

# If ASDF_CONCURRENCY is "auto" or not set, determine the number of CPU cores
if [[ "${local_concurrency:-auto}" == "auto" || -z "${local_concurrency}" ]]; then
  if command -v nproc >/dev/null 2>&1; then
    local_concurrency=$(nproc)
  elif [[ "$(uname)" == "Darwin" ]]; then
    local_concurrency=$(sysctl -n hw.ncpu)
  else
    local_concurrency=1 # Fallback if detection fails
  fi
fi

# Ensure ASDF_NODEJS_PLUGIN_DIR is set
ASDF_NODEJS_PLUGIN_DIR="${ASDF_NODEJS_PLUGIN_DIR:-$HOME/.asdf/plugins/nodejs}"

# Set ASDF_NODEJS_NODEBUILD_HOME, ensuring it defaults properly
ASDF_NODEJS_NODEBUILD_HOME="${ASDF_NODEJS_NODEBUILD_HOME:-$ASDF_NODEJS_PLUGIN_DIR/.node-build}"

# Calculate ASDF_NODEJS_CONCURRENCY based on local_concurrency
ASDF_NODEJS_CONCURRENCY=$(((local_concurrency + 1) / 2))

# node-build environment variables being overriden by asdf-nodejs
export NODE_BUILD_CACHE_PATH="${NODE_BUILD_CACHE_PATH:-$ASDF_NODEJS_CACHE_DIR/node-build}"

if [ "$NODEJS_ORG_MIRROR" ]; then
  export NODE_BUILD_MIRROR_URL="$NODEJS_ORG_MIRROR"
fi

if [[ "${ASDF_NODEJS_CONCURRENCY-}" =~ ^[0-9]+$ ]]; then
  export MAKE_OPTS="${MAKE_OPTS:-} -j$ASDF_NODEJS_CONCURRENCY"
  export NODE_MAKE_OPTS="${NODE_MAKE_OPTS:-} -j$ASDF_NODEJS_CONCURRENCY"
fi

nodebuild="${ASDF_NODEJS_NODEBUILD:-$ASDF_NODEJS_NODEBUILD_HOME/bin/node-build}"
args=()

if ! [ -x "$nodebuild" ]; then
  printf "Binary for node-build not found\n"

  if ! [ "${ASDF_NODEJS_NODEBUILD-}" ]; then
    printf "Are you sure it was installed? Try running \`asdf %s update-nodebuild\` to do a local update or install\n" "$(plugin_name)"
  fi

  exit 1
fi

if [ "${ASDF_NODEJS_VERBOSE_INSTALL-}" ]; then
  args+=(-v)
fi

exec "$nodebuild" ${args+"${args[@]}"} "$@"
