#!/usr/bin/env bash
#
# @file install/ubuntu/os_config.sh
# @brief Set OS configuration for Ubuntu.
# @description This script configures locale, timezone, and package repositories for Ubuntu.

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

# ターゲットパスを環境変数から上書き可能にする（テスト用）
APT_SOURCES_PATH="${APT_SOURCES_PATH:-/etc/apt/sources.list.d/ubuntu.sources}"

# @description Set the system locale to en_US.UTF-8.
# @noargs
function setup_locale() {
  local lang="en_US.UTF-8"
  sudo locale-gen "${lang}"
  if command -v localectl >/dev/null 2>&1; then
    sudo localectl set-locale LANG="${lang}"
  else
    sudo update-locale LANG="${lang}"
  fi
}

# @description Set the system timezone to Asia/Tokyo.
# @noargs
function setup_timezone() {
  local tz="Asia/Tokyo"
  if command -v timedatectl >/dev/null 2>&1; then
    sudo timedatectl set-timezone "${tz}"
  else
    sudo ln -snf /usr/share/zoneinfo/${tz} /etc/localtime
    echo "${tz}" | sudo tee /etc/timezone
  fi
}

# @description Configure APT repositories, replace default Ubuntu mirrors with a faster ones.
# @noargs
function setup_repositories() {
  # 変数化したパスを使用する
  if [[ -f "${APT_SOURCES_PATH}" ]]; then
    sudo sed -i.bak -r 's@http://(jp\.)?archive\.ubuntu\.com/ubuntu/?@https://ftp.udx.icscoe.jp/Linux/ubuntu/@g' "${APT_SOURCES_PATH}"
    sudo apt update
  fi
}

# @description Main entry point for this script.
# @noargs
function main() {
  info "Set OS configuration..."

  # コンテナ内ではロケール、タイムゾーン、aptレポジトリの設定はDockerfileで行うことが多いので実行しない
  if [ -e /.dockerenv ]; then
    info "Running inside a container, skipping locale and timezone setup."
  else
    setup_locale
    setup_timezone
    setup_repositories
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
