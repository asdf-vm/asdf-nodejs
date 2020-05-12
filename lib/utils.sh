# Helper functions

# TODO: Replace with an asdf variable once asdf starts providing the plugin name
# as a variable
plugin_name() {
  basename "$(dirname "$(dirname "$0")")"
}

ASDF_NODEJS_KEYRING=asdf-nodejs.gpg
