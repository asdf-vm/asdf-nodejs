echoerr() {
  printf "\033[0;31m%s\033[0m" "$1" >&2
}

ensure_node_build_installed() {
  if [ ! -f "$(node_build_path)" ]; then
    download_node_build
  fi
}

download_node_build() {
  echo "Downloading node-build..."
  local node_build_url="https://github.com/nodenv/node-build.git"
  git clone $node_build_url "$(node_build_root)"
}

node_build_root() {
  echo "$(dirname "$(dirname "$0")")/node-build"
}

node_build_path() {
  echo "$(node_build_root)/bin/node-build"
}
