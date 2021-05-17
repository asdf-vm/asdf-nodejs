# Helper functions

# When in China, set $NODEJS_ORG_MIRROR:
# export NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node/
NODEJS_ORG_MIRROR="${NODEJS_ORG_MIRROR:-https://nodejs.org/dist/}"
if [ ${NODEJS_ORG_MIRROR: -1} != / ]
then
  NODEJS_ORG_MIRROR=$NODEJS_ORG_MIRROR/
fi

ASDF_NODEJS_KEYRING=asdf-nodejs.gpg

ASDF_NODEJS_PLUGIN_NAME="$(basename "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")"
# TODO: Replace with an asdf variable once asdf starts providing the plugin name
# as a variable
plugin_name() {
  printf "%s\n" "$ASDF_NODEJS_PLUGIN_NAME"
}

ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"
export ASDF_NODEJS_PLUGIN_NAME ASDF_DIR

die() {
  >&2 echo "$@"
  exit 1
}

# Helper for outputting color, you can mix styles and colors using a semicolon
# Eg: `color "$BOLD;$RED" "Danger! Danger!"
color() {
  local color_str="${1-}"
  if [ $# -gt 0 ]; then shift; fi
  printf "\033[${color_str}m%s\033[0m" "$*"
}
BOLD=1
FAINT=2
UNDERLINE=4
RED=31
GREEN=32
YELLOW=33
BLUE=34
MAGENTA=35
CYAN=36

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

wrappers_check_and_notice() {
  if ! [ "${ASDF_NODEJS_DISABLE_WRAPPER_NOTICE-}" ] && ! check_for_wrappers_installed; then
    wrappers_notice
  fi
}

check_for_wrappers_installed() {
  grep -Fq "$(plugin_name)/wrappers/bin" <<< "$PATH"
}

wrappers_notice() {
  printf "\

$(color "$BOLD;$YELLOW" "Notice:") Because of some problems with auto-reshimming of global npm installs,
asdf-nodejs is experimenting with wrapping the npm executable instead
of relying in npm hooks. This approach will greatly improve global
installations time and should work in any version of npm/nodejs

To utilize the wrapper instead of the npm shim just link the file
\"wrappers/bin/npm\" from the plugin directory in your path $(color $UNDERLINE "before") the asdf shims
directory. There's an easy twoliner that you can put in your .bashrc or .zshrc
file, after activating asdf:

    asdf list $(plugin_name) > /dev/null 2>&1 && \\
        PATH=\"\$(asdf $(plugin_name) wrappers-path):\$PATH\"

Manual reshimming will still work, you can always run \`asdf reshim $(plugin_name)\`
after a npm global install/uninstall or disable auto-reshimming via the
ASDF_SKIP_RESHIM variable

To disable this notice just set the variable ASDF_NODEJS_DISABLE_WRAPPER_NOTICE=1

"
}

