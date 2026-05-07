#!/usr/bin/env bash
#
# @file install/utils.sh
# @brief Common utility functions for installation scripts.
# @description This script provides OS detection, logging, and color output
#   capabilities to be used across the dotfiles installation process.

# @description Initialize color variables for terminal output.
# @noargs
_set_colors() {
  if type -P tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
  fi

  if [[ -t 1 && -n "${ncolors:-}" && "$ncolors" -ge 8 ]]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    # shellcheck disable=SC2034
    RED="" GREEN="" YELLOW="" BLUE="" BOLD="" NORMAL=""
  fi
}

_set_colors

# @description Print an informational message to stdout.
# @arg $1 string The message to display.
# @stdout The informational message prefixed with "INFO" and colored green.
info() { printf "${GREEN}INFO${NORMAL} %s\n" "$1"; }

# @description Print a warning message to stdout.
# @arg $1 string The message to display.
# @stdout The warning message prefixed with "WARN" and colored yellow.
warn() { printf "${YELLOW}WARN${NORMAL} %s\n" "$1"; }

# @description Print an error message to stderr.
# @arg $1 string The message to display.
# @stderr The error message prefixed with "ERROR" and colored red.
error() { printf "${RED}ERROR${NORMAL} %s\n" "$1" >&2; }

# @description Detect the operating system distribution.
# @noargs
# @stdout The detected OS ID (e.g., ubuntu, darwin, windows).
os_type() {
  local os
  os="$(uname)"
  local os_release="${OS_RELEASE_PATH:-/etc/os-release}"

  if [[ "$os" == "Darwin" ]]; then
    echo "darwin"
  elif [[ "$os" == "Linux" ]]; then
    if [[ -f "${os_release}" ]]; then
      # shellcheck source=/dev/null
      (source "${os_release}" && echo "${ID}")
    else
      echo "linux"
    fi
  elif [[ "$(uname -s)" == "MINGW"* ]]; then
    echo "windows"
  else
    echo "unknown"
  fi
}

# @description Get the system architecture (x86_64, i686).
# @noargs
# @stdout The system architecture string.
os_bit() {
  uname -m
}

# @description Check if the script is running inside Windows Subsystem for Linux (WSL).
# @noargs
# @exitcode 0 If running in WSL.
# @exitcode 1 otherwise.
is_wsl() {
  if [[ "$(uname -r)" == *Microsoft* || "$(uname -r)" == *microsoft* ]]; then
    return 0
  else
    return 1
  fi
}
