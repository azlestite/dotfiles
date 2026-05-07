#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

readonly PACKAGES=(
  binutils-dev
  build-essential
  cmake
  libssl-dev
  libcurl4-openssl-dev
  libelf-dev
  libstdc++-12-dev
  zlib1g-dev
  libdw-dev
  libiberty-dev
)

function install_kcov_dependencies() {
  sudo apt update
  sudo apt install -y "${PACKAGES[@]}"
}

function install_kcov() {
  local url="https://github.com/SimonKagstrom/kcov"

  local temp_dir
  temp_dir=$(mktemp -d /tmp/kcov-XXXXXX)

  local version="v43"
  git clone "${url}" "${temp_dir}" -b "${version}" --depth 1

  cd "${temp_dir}" || exit 1
  mkdir build
  cd build
  cmake ..
  make
  sudo make install

  # Clean up
  cd - >/dev/null
  rm -rf "${temp_dir}"
}

function main() {
  install_kcov_dependencies
  install_kcov
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
