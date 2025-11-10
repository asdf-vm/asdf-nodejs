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
  local data_dir

  if [ "${ASDF_DATA_DIR-}" ]; then
    data_dir="${ASDF_DATA_DIR}"
  elif [ "${ASDF_DIR-}" ]; then
    data_dir="$ASDF_DIR"
  else
    data_dir="$HOME/.asdf"
  fi

  printf "%s\n" "$data_dir"
}

export ASDF_NODEJS_CACHE_DIR="$(asdf_data_dir)/tmp/$ASDF_NODEJS_PLUGIN_NAME/cache"

# Colors
colored() {
  local color="$1" text="$2"
  printf "\033[%sm%s\033[39;49m\n" "$color" "$text"
}

export RED=31 GREEN=32 YELLOW=33 BLUE=34 MAGENTA=35 CYAN=36

nodebuild_wrapped() {
  "$ASDF_NODEJS_PLUGIN_DIR/lib/commands/command-nodebuild" "$@"
}

try_to_update_nodebuild() {
  if [ "${ASDF_NODEJS_SKIP_NODEBUILD_UPDATE-}" ]; then
    return
  fi

  local exit_code=0

  "$ASDF_NODEJS_PLUGIN_DIR/lib/commands/command-update-nodebuild" 2>/dev/null || exit_code=$?

  if [ "$exit_code" != 0 ]; then
    printf "
$(colored $YELLOW WARNING): Updating node-build failed with exit code %s. The installation will
try to continue with already installed local defintions. To debug what went
wrong, try to manually update node-build by running: \`asdf %s update nodebuild\`
\n" "$exit_code" "$ASDF_NODEJS_PLUGIN_NAME"
  fi
}

# Adapted from asdf-core https://github.com/asdf-vm/asdf/blob/684f4f058f24cc418f77825a59a22bacd16a9bee/lib/utils.bash#L95-L109
list_installed_versions() {
  local plugin_name=$1

  local plugin_installs_path
  plugin_installs_path="$(asdf_data_dir)/installs/${plugin_name}"

  if [ -d "$plugin_installs_path" ]; then
    for install in "${plugin_installs_path}"/*/; do
      [[ -e "$install" ]] || break
      basename "$install" | sed 's/^ref-/ref:/'
    done
  fi
}

# stolen from https://github.com/rbenv/ruby-build/pull/631/files#diff-fdcfb8a18714b33b07529b7d02b54f1dR942
sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

resolve_legacy_version() {
  local strategy="$1" query="$2"
  local resolved=

  case "$strategy" in
  latest_installed)
    _list() {
      ASDF_NODEJS_SKIP_NODEBUILD_UPDATE=1 list_installed_versions nodejs | sort_versions
    }
    ;;

  latest_available)
    _list() {
      ASDF_NODEJS_SKIP_NODEBUILD_UPDATE=1 "$ASDF_NODEJS_PLUGIN_DIR/bin/list-all" "$query" | tr ' ' '\n'
    }
    ;;

  *)
    # Just return the original query
    printf "%s\n" "$query"
    return
  esac

  resolved=$(_list | grep "^$query" | tail -n1)

  if [ "$resolved" ]; then
    printf "%s\n" "$resolved"
  elif [ "$strategy" != latest_available ]; then
    # If no version is installed, fallback to latest_available, so `asdf install nodejs` works
    resolve_legacy_version latest_available "$query"
  else
    # Give up and pretty the query itself
    printf "%s\n" "$query"
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
    iron:20
    jod:22
    krypton:24
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
    local all_versions
    all_versions=$("$ASDF_NODEJS_PLUGIN_DIR/bin/list-all" 2>/dev/null | tr ' ' '\n')
    query=$(echo "$all_versions" | grep "^$query\." | tail -n1)
  fi

  if [ "${ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY-}" ]; then
    query=$(resolve_legacy_version "$ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY" "$query")
  fi

  printf "%s\n" "$query"
}
