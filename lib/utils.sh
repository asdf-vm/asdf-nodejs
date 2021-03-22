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

versions_cache_dir=~/.asdf/tmp/$(plugin_name)/cache
mkdir -p $versions_cache_dir

expire_file="$versions_cache_dir/expires"
index_file="$versions_cache_dir/index"
touch "$expire_file" "$index_file"

check_cache_expired() {
  current_time="$(date '+%s')"
  expire_time="$(<$expire_file)"
  [ "${expire_time:-0}" -le "${current_time:-0}" ]
}
cache_index_tab(){
  local index_tab_url="${NODEJS_ORG_MIRROR}index.tab"
  # Cache expired or doesn't exist: refetch
  output="$(curl --fail --silent "$index_tab_url" 2>&1)"
  if [ "$?" -ne 0 ]; then
    die "Failed to fetch index.tab: $output"
  fi
  echo "$output" | filter_version_candidates > "$index_file"
  curl --fail --silent --head "$index_tab_url" |
    awk -v time="$(date '+%s')" '
        /^age: /{age=int(substr($0, 5))};
        /cache-control: /{max=int(substr($0, match($0, /max-age=/)+8))};
        END{print int(time) + max - age}' \
          > "$expire_file"
}

print_index_tab() {
  check_cache_expired && cache_index_tab
  cat <"$index_file"
}
