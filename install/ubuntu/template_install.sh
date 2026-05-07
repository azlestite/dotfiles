#!/usr/bin/env bash
#
# template file for installation scripts

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

readonly UTILS_PATH="${CHEZMOI_REPO_ROOT:-$(dirname "${BASH_SOURCE[0]}")/..}/install/utils.sh"

if [[ -f "${UTILS_PATH}" ]]; then
  # shellcheck source=/dev/null
  source "${UTILS_PATH}"
else
  echo "Error: utils.sh not found at ${UTILS_PATH}" >&2
  exit 1
fi

function install_xxx() {
  # Add logic here
  :
}

function uninstall_xxx() {
  # Add logic here
  :
}

function main() {
  info "Install xxx..."
  # Add dependency checks or pre-install logic if needed
  install_xxx
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
