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

# TODO: implement a cache for the tab. The api supports If-None-Match and
# If-Modified-Since HTTP headers
print_index_tab() {
  curl --silent "${NODEJS_ORG_MIRROR}index.tab"
}

# Tab file needs to be piped as stdin
# Print all alias and correspondent versions in the format "$alias\t$version"
# Also prints versions as a alias of itself. Eg: "v10.0.0\tv10.0.0"
filter_version_candidates() {
  local curr_line=""
  local -A aliases

  # Skip headers
  IFS= read -r curr_line

  while IFS= read -r curr_line; do
    # Just expanding the string should work because tabs are considered array separators
    local -a fields=($curr_line)

    # Version without `v` prefix
    local version="${fields[0]#v}"
    # Lowercase lts codename, `-` if not a lts version
    local lts="${fields[9],,}"

    if [ "$lts" != - ]; then
      # No lts read yet, so this must be the more recent
      if [ -z "${aliases[lts]:-}" ]; then
        printf "lts\t%s\n" "$version"
        aliases[lts]="$version"
      fi

      # No lts read for this codename yet, so this must be the more recent
      if [ -z "${aliases[$lts]:-}" ]; then
        printf "lts-$lts\t%s\n" "$version"
        aliases[$lts]="$version"
      fi
    fi

    printf "%s\t%s\n" "$version" "$version"
  done
}

