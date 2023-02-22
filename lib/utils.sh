# Helper functions

# When in China, set $NODEJS_ORG_MIRROR:
# export NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node/
NODEJS_ORG_MIRROR="${NODEJS_ORG_MIRROR:-https://nodejs.org/dist/}"
if [ ${NODEJS_ORG_MIRROR: -1} != / ]
then
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

die() {
  >&2 echo "$@"
  exit 1
}

delete_on_exit() {
  trap "rm -rf $@" EXIT
}

# Tab file needs to be piped as stdin
# Print all alias and correspondent versions in the format "$alias\t$version"
# Also prints versions as a alias of itself. Eg: "v10.0.0\tv10.0.0"
filter_version_candidates() {
  local curr_line= aliases= definitions=

  definitions=$(nodebuild_wrapped --definitions)

  # Skip headers
  IFS= read -r curr_line

  while IFS= read -r curr_line; do
    # Just expanding the string should work because tabs are considered array separators
    local -a fields=($curr_line)

    # Version without `v` prefix
    local version="${fields[0]#v}"
    # Lowercase lts codename, `-` if not a lts version
    local lts_codename=$(echo "${fields[9]}" | tr '[:upper:]' '[:lower:]')

    # If not available in nodebuild skip it
    if ! grep -q "^$version$" <<< "$definitions"; then
      continue
    fi

    if [ "$lts_codename" != - ]; then
      # No lts read yet, so this must be the more recent
      if ! grep -q "^lts:" <<< "$aliases"; then
        printf "lts\t%s\n" "$version"
        aliases="$aliases"$'\n'"lts:$version"
      fi

      # No lts read for this codename yet, so this must be the more recent
      if ! grep -q "^$lts_codename:" <<< "$aliases"; then
        printf "lts-$lts_codename\t%s\n" "$version"
        aliases="$aliases"$'\n'"$lts_codename:$version"
      fi
    fi

    printf "%s\t%s\n" "$version" "$version"
  done
}

versions_cache_dir="$ASDF_NODEJS_CACHE_DIR/versions-tab"
mkdir -p "$versions_cache_dir"

etag_file="$versions_cache_dir/etag"
index_file="$versions_cache_dir/index"

print_index_tab(){
  local temp_headers_file= index= curl_opts=()

  temp_headers_file=$(mktemp)
  delete_on_exit "$temp_headers_file"

  if [ -r "$etag_file" ]; then
    curl_opts=(--header "If-None-Match: $(cat "$etag_file")")
  fi

  index=$(curl --fail --silent --location --dump-header "$temp_headers_file" ${curl_opts+"${curl_opts[@]}"}  "${NODEJS_ORG_MIRROR}index.tab")

  if [ "$index" ]; then
    awk 'tolower($1) == "etag:" { print $2 }' < "$temp_headers_file" > "$etag_file"
    printf "%s\n" "$index" > "$index_file"
  fi

  # The `cat` indirection is for a bash3 printf broken pipe error
  # https://github.com/asdf-vm/asdf-nodejs/issues/300
  cat <(filter_version_candidates < "$index_file")
}

nodebuild_wrapped() {
  "$ASDF_NODEJS_PLUGIN_DIR/lib/commands/command-nodebuild.bash" "$@"
}
