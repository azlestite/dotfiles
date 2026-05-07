#!/usr/bin/env bash
#
# @file install/ubuntu/bitwarden_cli.sh
# @brief Install Bitwarden CLI on Ubuntu.
# @description Checks for required dependencies, downloads the Bitwarden CLI binary, and sets up the environment for usage.

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

# @description Install Bitwarden CLI by downloading the latest release and setting it up in the user's local bin directory.
# @noargs
function install_bitwarden_cli() {
  mkdir -p "${HOME}"/.local/{bin,src}
  curl -fsSL "https://bitwarden.com/download/?app=cli&platform=linux" -o "${HOME}"/.local/src/bw-linux.zip
  unzip "${HOME}"/.local/src/bw-linux.zip -d "${HOME}"/.local/bin/
  chmod +x "${HOME}"/.local/bin/bw
  rm -rf "${HOME}"/.local/src/bw-linux.zip

  export PATH="$HOME/.local/bin:$PATH"
  # source $HOME/.profile
  bw login
  bw sync
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
}

function login_bitwarden_cli() {
  bw login
  bw sync
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
}

# @description Uninstall Bitwarden CLI by removing the binary and unsetting related environment variables.
# @noargs
function uninstall_bitwarden_cli() {
  rm -rf "$HOME"/.local/bin/bw
  unset BW_SESSION
}

# @description Main function to orchestrate the installation of Bitwarden CLI.
# @noargs
function main() {
  info "Install Bitwarden CLI..."
  # Add dependency checks or pre-install logic if needed
  install_bitwarden_cli
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
