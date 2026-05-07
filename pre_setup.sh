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
  # Install prerequisite packages for the setup.
  # This can include packages like curl, git, etc. that are required for the setup process.
  # For example:
  sudo apt update
  sudo apt install -y curl git unzip wget

  # bwコマンドが既に存在し、BW_SESSION環境変数も設定されている場合はスキップ
  # BW_SESSIONが設定されていない場合はBW_SESSION="$(bw unlock --raw)"を実行して環境変数を設定する
  # どちらも条件を満たさない場合は、Bitwarden CLIのインストールスクリプトを現在のシェルで実行する
  if command -v bw >/dev/null 2>&1; then
    echo "Bitwarden CLI is already installed. Checking BW_SESSION..."
    if [ -n "${BW_SESSION:-}" ]; then
      echo "BW_SESSION is already set. Skipping Bitwarden CLI login and unlock."
    else
      echo "BW_SESSION is not set. Attempting to unlock Bitwarden CLI session..."
      # bw login
      # bw sync
      # BW_SESSION="$(bw unlock --raw)"
      # export BW_SESSION
      # source "install/ubuntu/bitwarden_cli.sh"
      # echo $(dirname "${BASH_SOURCE[0]}")
      login_bitwarden_cli
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

function main() {
  install_prerequisite_packages
}

# source setup.sh in the current shell to ensure that environment variables are properly set
main
