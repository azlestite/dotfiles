#!/usr/bin/env bash
#
# @file setup.sh
# @brief Main setup script for Ubuntu.
# @description This script sets up the system locale, timezone, and APT repositories for Ubuntu

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

function install_prerequisite_packages() {
  sudo apt update
  sudo apt install -y curl git unzip wget

  if command -v bw >/dev/null 2>&1; then
    echo "Bitwarden CLI is already installed. Checking BW_SESSION..."

    if [[ -z "${BW_SESSION}" ]]; then
      echo "BW_SESSION is not set. Unlock Bitwarden CLI..."
      login_and_unlock_bitwarden_cli
    else
      echo "BW_SESSION is already set. Skipping..."
    fi
  else
    install_bitwarden_cli
  fi
}

function install_bitwarden_cli() {
  mkdir -p "${HOME}"/.local/{bin,src}
  curl -fsSL "https://bitwarden.com/download/?app=cli&platform=linux" -o "${HOME}"/.local/src/bw-linux.zip
  unzip "${HOME}"/.local/src/bw-linux.zip -d "${HOME}"/.local/bin/
  chmod +x "${HOME}"/.local/bin/bw
  rm -rf "${HOME}"/.local/src/bw-linux.zip

  export PATH="$HOME/.local/bin:$PATH"
  # source $HOME/.profile
  login_and_unlock_bitwarden_cli
}

function login_and_unlock_bitwarden_cli() {
  bw login
  bw sync
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
}

function main() {
  install_prerequisite_packages
}

# source setup.sh in the current shell to ensure that environment variables are properly set
main
