#!/usr/bin/env bash
#
# @file setup.sh
# @brief Main setup script for Ubuntu.
# @description This script sets up the system locale, timezone, and APT repositories for Ubuntu

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# shellcheck disable=SC2016
declare -r DOTFILES_LOGO='
                          /$$                                      /$$
                         | $$                                     | $$
     /$$$$$$$  /$$$$$$  /$$$$$$   /$$   /$$  /$$$$$$      /$$$$$$$| $$$$$$$
    /$$_____/ /$$__  $$|_  $$_/  | $$  | $$ /$$__  $$    /$$_____/| $$__  $$
   |  $$$$$$ | $$$$$$$$  | $$    | $$  | $$| $$  \ $$   |  $$$$$$ | $$  \ $$
    \____  $$| $$_____/  | $$ /$$| $$  | $$| $$  | $$    \____  $$| $$  | $$
    /$$$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$/| $$$$$$$//$$ /$$$$$$$/| $$  | $$
   |_______/  \_______/   \___/   \______/ | $$____/|__/|_______/ |__/  |__/
                                           | $$
                                           | $$
                                           |__/

             *** This is setup script for my dotfiles setup ***
                     https://github.com/azlestite/dotfiles
'

declare -r DOTFILES_REPO_URL="https://github.com/azlestite/dotfiles"
declare -r BRANCH_NAME="${BRANCH_NAME:-main}"

function is_ci() {
  "${CI:-false}"
}

function is_tty() {
  [ -t 0 ]
}

function is_not_tty() {
  ! is_tty
}

function is_ci_or_not_tty() {
  is_ci || is_not_tty
}

function get_os_type() {
  uname
}

function keepalive_sudo_linux() {
  # Might as well ask for password up-front, right?
  echo "Checking for \`sudo\` access which may request your password."
  sudo -v

  # Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

function keepalive_sudo() {

  local ostype
  ostype="$(get_os_type)"

  if [ "${ostype}" == "Linux" ]; then
    keepalive_sudo_linux
  else
    echo "Invalid OS type: ${ostype}" >&2
    exit 1
  fi
}

function run_chezmoi() {
  local bin_dir="${HOME}/.local/bin"
  export PATH="${PATH}:${bin_dir}"

  # download the chezmoi binary from the URL
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${bin_dir}"
  local chezmoi_cmd="${bin_dir}/chezmoi"

  if is_ci_or_not_tty; then
    no_tty_option="--no-tty" # /dev/tty is not available (especially in the CI)
  else
    no_tty_option="" # /dev/tty is available OR not in the CI
  fi
  # run `chezmoi init` to setup the source directory,
  # generate the config file, and optionally update the destination directory
  # to match the target state.
  "${chezmoi_cmd}" init "${DOTFILES_REPO_URL}" \
    --force \
    --branch "${BRANCH_NAME}" \
    --use-builtin-git true \
    ${no_tty_option}

  # the `age` command requires a tty, but there is no tty in the github actions.
  # Therefore, it is currnetly difficult to decrypt the files encrypted with `age` in this workflow.
  # I decided to temporarily remove the encrypted target files from chezmoi's control.
  if is_ci_or_not_tty; then
    find "$(${chezmoi_cmd} source-path)" -type f -name "encrypted_*" -exec rm -fv {} +
  fi

  # Add to PATH for installing the necessary binary files under `$HOME/.local/bin`.
  export PATH="${PATH}:${HOME}/.local/bin"

  # run `chezmoi apply` to ensure that target... are in the target state,
  # updating them if necessary.
  "${chezmoi_cmd}" apply ${no_tty_option}

  # purge the binary of the chezmoi cmd
  rm -fv "${chezmoi_cmd}"
}

function initialize_dotfiles() {

  if ! is_ci_or_not_tty; then
    # - /dev/tty of the github workflow is not available.
    # - We can use password-less sudo in the github workflow.
    # Therefore, skip the sudo keep alive function.
    keepalive_sudo
  fi
  # run_chezmoi
  echo "Initializing dotfiles with chezmoi..."
}

function check_prerequisite_packages() {
  # bwコマンドが存在し、BW_SESSION環境変数も設定されている場合は問題ないのでスキップ
  # それ以外の場合は、環境変数を設定するため現在のシェルでpre_setup.shを実行する
  if command -v bw >/dev/null 2>&1; then
    echo "Bitwarden CLI is already installed. Checking BW_SESSION..."
    if [ -n "${BW_SESSION:-}" ]; then
      echo "BW_SESSION is already set. Skipping Bitwarden CLI login and unlock."
    else
      echo "BW_SESSION is not set."
      echo "Run 'source pre_setup.sh' to install Bitwarden CLI and set BW_SESSION environment variable."
      exit 1
    fi
  else
    echo "Run 'source pre_setup.sh' to install Bitwarden CLI and set BW_SESSION environment variable."
    exit 1
  fi

}

function install_prerequisite_packages() {
  sudo apt update
  sudo apt install -y curl git unzip wget

  if command -v bw >/dev/null 2>&1; then
    echo "Bitwarden CLI is already installed. Checking BW_SESSION..."

    if [[ -z "${BW_SESSION:-}" ]]; then
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
  echo "${DOTFILES_LOGO}"

  # check_prerequisite_packages

  install_prerequisite_packages

  initialize_dotfiles
  echo "BW_SESSION: ${BW_SESSION}"

  # restart_shell # Disabled because the at_exit function does not work properly.

  # curl -fsSL https://raw.githubusercontent.com/azlestite/dotfiles/main/pre_setup.sh -o /tmp/pre_setup.sh && source /tmp/pre_setup.sh && rm -rf /tmp/pre_setup.sh && echo $BW_SESSION

  # git clone https://github.com/azlestite/dotfiles . && source pre_setup.sh && echo $BW_SESSION

  # source pre_setup.sh && echo $BW_SESSION && ./setup.sh
}

# source setup.sh in the current shell to ensure that environment variables are properly set
main
