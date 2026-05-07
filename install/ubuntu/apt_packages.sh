#!/usr/bin/env bash
#
# @file install/ubuntu/apt_packages.sh
# @brief Install necessary APT packages for Ubuntu.
# @description This script checks for the presence of required APT packages and
#   installs any that are missing.
#   It also provides a function to uninstall these packages if needed.

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# CHEZMOI_REPO_ROOT があればそれを使用、なければ相対パスで解決
# ${VARIABLE:-DEFAULT} の形式を使うと非常に短く書けます
readonly UTILS_PATH="${CHEZMOI_REPO_ROOT:-$(dirname "${BASH_SOURCE[0]}")/..}/install/utils.sh"

if [[ -f "${UTILS_PATH}" ]]; then
  # shellcheck source=/dev/null
  source "${UTILS_PATH}"
else
  echo "Error: utils.sh not found at ${UTILS_PATH}" >&2
  exit 1
fi

PACKAGES=(
  build-essential
  libssl-dev
  pkg-config
  cmake
  ca-certificates
  wl-clipboard
  xsel
  gawk
  make
)

# @description Check for missing packages and install them using APT.
# @noargs
function install_apt_packages() {
  local missing_packages=()
  local package

  for package in "${PACKAGES[@]}"; do
    if ! dpkg -l "${package}" >/dev/null 2>&1; then
      missing_packages+=("${package}")
    fi
  done

  if [ "${#missing_packages[@]}" -eq 0 ]; then
    echo "All packages are already installed."
    return 0
  fi

  sudo apt update
  sudo apt install -y "${missing_packages[@]}"
}

# @description Uninstall the APT packages defined in the PACKAGES array.
# @noargs
function uninstall_apt_packages() {
  if [ "${#PACKAGES[@]}" -eq 0 ]; then
    echo "No packages defined to uninstall."
    return 0
  fi

  sudo apt remove -y "${PACKAGES[@]}"
}

# @description Main entry point for this script.
# @noargs
function main() {
  info "Install packages..."
  install_apt_packages
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
