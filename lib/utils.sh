# Helper functions

# When in China, set $NODEJS_ORG_MIRROR:
# export NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node/
NODEJS_ORG_MIRROR="${NODEJS_ORG_MIRROR:-https://nodejs.org/dist/}"
if [ ${NODEJS_ORG_MIRROR: -1} != / ]; then
  NODEJS_ORG_MIRROR=$NODEJS_ORG_MIRROR/
fi

export ASDF_NODEJS_PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# TODO: Replace with an asdf variable once asdf starts providing the plugin name
# as a variable
export ASDF_NODEJS_PLUGIN_NAME=$(basename "$ASDF_NODEJS_PLUGIN_DIR")
plugin_name() {
  printf "%s\n" "$ASDF_NODEJS_PLUGIN_NAME"
}

asdf_data_dir() {
  printf "%s\n" "${ASDF_DATA_DIR:-$HOME/.asdf}"
}

export ASDF_NODEJS_CACHE_DIR="$(asdf_data_dir)/tmp/$ASDF_NODEJS_PLUGIN_NAME/cache"

# Colors
colored() {
  local color="$1" text="$2"
  printf "\033[%sm%s\033[39;49m\n" "$color" "$text"
}

export RED=31 GREEN=32 YELLOW=33 BLUE=34 MAGENTA=35 CYAN=36

nodebuild_wrapped() {
  "$ASDF_NODEJS_PLUGIN_DIR/lib/commands/command-nodebuild.bash" "$@"
}

try_to_update_nodebuild() {
  local exit_code=0

  "$ASDF_NODEJS_PLUGIN_DIR/lib/commands/command-update-nodebuild.bash" 2>/dev/null || exit_code=$?

  if [ "$exit_code" != 0 ]; then
    printf "
$(colored $YELLOW WARNING): Updating node-build failed with exit code %s. The installation will
try to continue with already installed local defintions. To debug what went
wrong, try to manually update node-build by running: \`asdf %s update nodebuild\`
\n" "$exit_code" "$ASDF_NODEJS_PLUGIN_NAME"
  fi
}

resolve_version() {
  local query=
  query=$(tr '[:upper:]' '[:lower:]' <<<"${1#v}")

  if [[ $query = lts-* ]]; then
    query=$(tr - / <<<"$query")
  fi

  local nodejs_codenames=(
    argon:4
    boron:6
    carbon:8
    dubnium:10
    erbium:12
    fermium:14
    gallium:16
    hydrogen:18
  )

  for cod_version in "${nodejs_codenames[@]}"; do
    local codename="${cod_version%:*}"
    local version_number="${cod_version#*:}"

    if [ "${query#lts/}" = "$codename" ]; then
      query="$version_number"
      break
    fi
  done

  if [ "$query" = lts ] || [ "$query" = "lts/*" ]; then
    query="${nodejs_codenames[${#nodejs_codenames[@]} - 1]#*:}"
  fi

  if [ "${ASDF_NODEJS_RESOLVE_VERSION_CMD-}" ]; then
    query=$(bash -c "$ASDF_NODEJS_RESOLVE_VERSION_CMD" -- "$query")
  fi

  printf "%s\n" "$query"
}
