# Helper functions

# When in China, set $NODEJS_ORG_MIRROR:
# export NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node/
NODEJS_ORG_MIRROR="${NODEJS_ORG_MIRROR:-https://nodejs.org/dist/}"
if [ ${NODEJS_ORG_MIRROR: -1} != / ]
then
  NODEJS_ORG_MIRROR=$NODEJS_ORG_MIRROR/
fi

# TODO: Replace with an asdf variable once asdf starts providing the plugin name
# as a variable
plugin_name() {
  basename "$(dirname "$(dirname "$0")")"
}

die() {
  >&2 echo "$@"
  exit 1
}

ASDF_NODEJS_KEYRING=asdf-nodejs.gpg

# TODO: implement a cache for the tab. The api supports If-None-Match and
# If-Modified-Since HTTP headers
print_index_tab() {
  curl --silent "${NODEJS_ORG_MIRROR}index.tab"
}

# Print all alias and correspondent versions in the format "$alias\t$version"
# Also prints versions as a alias of itself. Eg: "v10.0.0	v10.0.0"
filter_version_candidates() {
  awk -F'\t' '
    # First line is the headers for the columns
    NR == 1 {
      for (i = 1; i <= NF; i++) {
        cols[cols_size++] = $i
      }

      # Skip first line because we got all the information already
      next
    }

    # Add a global variable `record` with the current line version
    # using the headers as fields
    {
      for (i = 1; i < NF; i++) {
        record[cols[i - 1]] = $i
      }
    }

    {
      # Version without the `v` prefix
      vers = substr(record["version"], 2) 

      # We need to check if the lts alias is in a variable because multiple versions
      # have the same alias, we want to print only the most recent
      if (record["lts"] != "-") {

        # Check if lts is already printed, if not print it as version candidate and
        # put it at the aliases map
        if (!("lts" in aliases)) {
          aliases["lts"] = vers
          print "lts\t" vers
        }

        lts_alias = "lts-" tolower(record["lts"])
        if (!(lts_alias in aliases)) {
          aliases[lts_alias] = vers
          print lts_alias "\t" vers
        }
      }

      print vers "\t" vers
    }
  '
}
