export NODE_BUILD_VERSION="${ASDF_NODE_BUILD_VERSION:-v4.9.33}"
echoerr() {
  >&2 echo -e "\033[0;31m$1\033[0m"
}

ensure_node_build_setup() {

  export NODE_BUILD_MIRROR_URL="${ASDF_NODE_BUILD_MIRROR_URL:-https://nodejs.org/dist/}"
  export NODE_BUILD_CACHE_PATH="$(node_build_path)/cache"
  ensure_node_build_installed
}

ensure_node_build_installed() {
  # If node-build exists
  if [ -x "$(node_build_executable)" ]; then
    # But was passed an expected version
    if [ -n "${ASDF_NODE_BUILD_VERSION:-}" ]; then
      current_node_build_version="v$("$(node_build_executable)" --version | cut -d ' ' -f2)"
      # Check if expected version matches current version
      if [ "$current_node_build_version" != "$NODE_BUILD_VERSION" ]; then
        # If not, reinstall with ASDF_NODE_BUILD_VERSION
        download_node_build
      fi
    fi
  else
    # node-build does not exist, so install using default value in NODE_BUILD_VERSION
    download_node_build
  fi
}



download_node_build() {
  # Remove directory in case it still exists from last download
  rm -rf "$(node_build_source_path)"
  rm -rf "$(node_build_path)"
  # Print to stderr so asdf doesn't assume this string is a list of versions
  echoerr "Downloading node-build $NODE_BUILD_VERSION"



  # Clone down and checkout the correct node-build version
  git clone https://github.com/nodenv/node-build.git "$(node_build_source_path)" --quiet
  (cd "$(node_build_source_path)"; git checkout $NODE_BUILD_VERSION --quiet;)

  echo "$(cd $(node_build_source_path); PREFIX=$(node_build_path) ./install.sh)" 2>&1 >/dev/null

  rm -rf "$(node_build_source_path)"
}

asdf_nodejs_plugin_path() {
  echo "$(dirname "$(dirname "$0")")"
}

plugin_name() {
  basename $(asdf_nodejs_plugin_path)
}

node_build_path() {
  echo "$(asdf_nodejs_plugin_path)/node-build"
}

node_build_source_path() {
  echo "$(node_build_path)-source"
}


node_build_executable() {
  #Check if node-build exists without an expected version
  if [ -x "$(command -v node-build)" ] && [ -z "${ASDF_NODE_BUILD_VERSION:-}" ]; then
    echo "$(command -v node-build)"
  else
    echo "$(node_build_path)/bin/node-build"
  fi
}
