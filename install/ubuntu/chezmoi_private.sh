#!/usr/bin/env bash
#
# @file install/ubuntu/chezmoi_private.sh
# @brief Install private dotfiles using chezmoi.
# @description Initializes the private dotfiles repository and applies the configuration.

set -Eeuo pipefail

declare -r PRIVATE_DOTFILES_REPO_URL="https://github.com/azlestite/dotfiles-private"
declare -r PRIVATE_DOTFILES_PATH="${HOME}/.local/share/chezmoi-private"
declare -r PRIVATE_DOTFILES_CONFIG_PATH="${HOME}/.config/chezmoi-private/chezmoi.toml"

if [ "${DOTFILES_DEBUG:-}" ]; then
  set -x
fi

# @description Initialize the private dotfiles repository if it is available.
# @noargs
function install_chezmoi_private() {
  if chezmoi init \
    --apply \
    --ssh \
    --source "${PRIVATE_DOTFILES_PATH}" \
    --config "${PRIVATE_DOTFILES_CONFIG_PATH}" \
    "${PRIVATE_DOTFILES_REPO_URL}"; then
    return 0
  fi

  echo "Warning: Failed to initialize dotfiles-private. Skipping private dotfiles setup." >&2
}

# @description Remove the private chezmoi source and config paths.
# @noargs

function uninstall_chezmoi_private() {
  rm -rfv "${PRIVATE_DOTFILES_PATH}"
  rm -rfv "${PRIVATE_DOTFILES_CONFIG_PATH}"
}

# @description Run the private chezmoi initialization flow.
# @noargs
function main() {
  # source ~/.bashrc

  # Use gpg-agent instead of ssh-agent
  if ! pgrep -x -u "${USER:-$(whoami)}" gpg-agent >/dev/null 2>&1; then
    echo "Starting gpg-agent..."
    gpg-connect-agent /bye >/dev/null 2>&1
  fi

  # unset SSH_AGENT_PID
  # echo "gnupg_SSH_AUTH_SOCK_by: ${gnupg_SSH_AUTH_SOCK_by:-0}"
  # if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  #   SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  #   export SSH_AUTH_SOCK
  # fi

  # GPG_TTY=$(tty)
  # export GPG_TTY

  install_chezmoi_private
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
