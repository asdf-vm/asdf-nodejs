# Helper functions

# When in China, set $NODEJS_ORG_MIRROR:
# export NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node/
NODEJS_ORG_MIRROR="${NODEJS_ORG_MIRROR:-https://nodejs.org/dist/}"
if [ ${NODEJS_ORG_MIRROR: -1} != / ]
then
  NODEJS_ORG_MIRROR=$NODEJS_ORG_MIRROR/
fi

ASDF_NODEJS_KEYRING=asdf-nodejs.gpg

# TODO: Replace with an asdf variable once asdf starts providing the plugin name
# as a variable
plugin_name() {
  basename "$(dirname "$(dirname "$0")")"
}

die() {
  >&2 echo "$@"
  exit 1
}

# Tab file needs to be piped as stdin
# Print all alias and correspondent versions in the format "$alias\t$version"
# Also prints versions as a alias of itself. Eg: "v10.0.0\tv10.0.0"
filter_version_candidates() {
  local curr_line="" aliases=""

  # Skip headers
  IFS= read -r curr_line

  while IFS= read -r curr_line; do
    # Just expanding the string should work because tabs are considered array separators
    local -a fields=($curr_line)

    # Version without `v` prefix
    local version="${fields[0]#v}"
    # Lowercase lts codename, `-` if not a lts version
    local lts_codename=$(echo "${fields[9]}" | tr '[:upper:]' '[:lower:]')

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

versions_cache_dir="${ASDF_DATA_DIR:-${ASDF_HOME:-$HOME/.asdf}}/tmp/$(plugin_name)/cache"
mkdir -p "$versions_cache_dir"

etag_file="$versions_cache_dir/etag"
index_file="$versions_cache_dir/index"
touch "$etag_file" "$index_file"

print_index_tab(){
  local temp_headers_file="$(mktemp)"

  if [ -f "$etag_file" ]; then
    etag_flag='--header If-None-Match:'"$(cat "$etag_file")"
  fi

  index="$(curl --fail --silent --dump-header "$temp_headers_file" $etag_flag  "${NODEJS_ORG_MIRROR}index.tab")"
  if [ -z "$index" ]; then
    cat "$index_file"
  else
    cat "$temp_headers_file" | awk 'tolower($1) == "etag:" { print $2 }' > "$etag_file"
    echo "$index" | filter_version_candidates | tee "$index_file"
  fi

  rm "$temp_headers_file"
}
