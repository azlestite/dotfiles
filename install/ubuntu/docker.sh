#!/usr/bin/env bash
#
# @file install/ubuntu/docker.sh
# @brief Install Docker Engine on Ubuntu.
# @description Removes legacy Docker packages, configures Docker's apt repository, and
#   installs the current Docker Engine packages.

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

readonly PACKAGES=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
)

# @description Remove legacy Docker packages that conflict with Docker Engine.
# @noargs
function uninstall_old_docker() {
  local remove_packages=(
    docker.io
    docker-compose
    docker-compose-v2
    docker-doc
    podman-docker
    containerd
    runc
  )

  local installed_pkgs
  installed_pkgs=$(dpkg --get-selections "${remove_packages[@]}" 2>/dev/null | cut -f1 || true)

  if [ -n "$installed_pkgs" ]; then
    # 変数をクォートせずに渡し、空白区切りで複数の引数として扱う
    # shellcheck disable=SC2086
    sudo apt remove -y $installed_pkgs
  else
    echo "No legacy packages found. Skipping uninstall."
  fi
}

# @description Configure Docker's official apt repository and signing key.
# @noargs
function setup_repository() {

  # Add Docker's official GPG key:
  sudo apt update
  sudo apt install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources:
  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
}

# @description Install Docker Engine and the configured companion packages.
# @noargs
function install_docker_engine() {
  sudo apt update
  sudo apt install -y "${PACKAGES[@]}"
  # Run docker as non-root user
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"
}

# @description Uninstall Docker Engine and the configured companion packages.
# @noargs
function uninstall_docker_engine() {
  sudo apt remove -y "${PACKAGES[@]}" || echo "Some packages were not found, skipping."
}

# @description Main entry point for this script.
# @noargs
function main() {
  info "Install docker..."
  # コンテナ内ではDocker Engineのインストールは行わない
  if [ -e /.dockerenv ]; then
    info "Running inside a container, skipping Docker Engine installation."
    return 0
  fi

  uninstall_old_docker
  setup_repository
  install_docker_engine
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
