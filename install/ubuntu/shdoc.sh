#!/usr/bin/env bash
#
# @file install/ubuntu/shdoc.sh
# @brief Installer for shdoc (Shell Documentation Generator).
# @description This script clones the shdoc repository, builds it, and installs it on the system.

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

SHDOC_REPO="https://github.com/reconquest/shdoc"

# @description Install shdoc and its dependencies.
# @noargs
function install_shdoc() {
  temp_dir=$(mktemp -d)
  git clone --recursive "$SHDOC_REPO" "$temp_dir"
  cd "$temp_dir"
  sudo make install
  # Clean up
  cd - >/dev/null
  rm -rf "$temp_dir"
}

# @description Uninstall shdoc.
# @noargs
function uninstall_shdoc() {
  local bin_path
  bin_path=$(command -v shdoc)
  if [[ -n "$bin_path" ]]; then
    info "Removing shdoc from $bin_path"
    sudo rm -f "$bin_path"
  else
    warn "shdoc is not installed, nothing to remove."
  fi
}

# @description Main entry point for this script.
# @noargs
function main() {
  if command -v shdoc >/dev/null 2>&1; then
    info "shdoc is already installed."
  else
    info "Install shdoc..."
    install_shdoc
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
