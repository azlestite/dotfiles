#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/apt_packages.sh"

function dump_output() {
  echo -e "\n--- DEBUG EXECUTION LOG (Test: ${BATS_TEST_DESCRIPTION}) ---" >&3
  echo "$output" >&3
  echo -e "-----------------------------------------------------------\n" >&3
}

function setup() {
  function sudo() {
    local cmd="$1"
    shift
    echo -n "sudo "
    if [ "$(type -t "$cmd")" = "function" ]; then
      "$cmd" "$@"
    else
      echo "$cmd $*"
    fi
  }
  export -f sudo

  function apt() { echo "apt $*"; }
  export -f apt

  source "${SCRIPT_PATH}"
}

@test "validation: script file should exist and be executable" {
  [ -f "${SCRIPT_PATH}" ]
  [ -x "${SCRIPT_PATH}" ]
}

@test "validation: default PACKAGES list should contain the expected number of tools" {
  # readonlyを外したため、意図せず中身が消えていないかチェック
  [ "${#PACKAGES[@]}" -eq 9 ]
}

@test "install_apt_packages: should install all packages when none are present" {
  # テスト用にリストを上書き
  PACKAGES=("vim" "tmux")

  function dpkg() { return 1; } # 全て未インストール
  export -f dpkg

  run install_apt_packages
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt install -y vim tmux"* ]]
}

@test "install_apt_packages: should skip installation when all packages are already installed" {
  PACKAGES=("vim" "tmux" "htop")

  function dpkg() { return 0; } # 全てインストール済み
  export -f dpkg

  run install_apt_packages
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"All packages are already installed."* ]]
  [[ "$output" != *"sudo apt install"* ]]
}

@test "install_apt_packages: should skip already installed packages and only install missing ones" {
  PACKAGES=("vim" "tmux" "htop")

  # vimのみインストール済みというシナリオ
  function dpkg() {
    if [[ "$2" == "vim" ]]; then
      return 0
    fi
    return 1
  }
  export -f dpkg

  run install_apt_packages
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt install -y tmux htop"* ]]
  [[ "$output" != *"vim"* ]]
}

@test "install_apt_packages: should do nothing when PACKAGES list is empty" {
  PACKAGES=()

  run install_apt_packages
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"All packages are already installed."* ]]
  [[ "$output" != *"sudo apt install"* ]]
}

@test "uninstall_apt_packages: should remove only the packages currently in the list" {
  PACKAGES=("htop" "git")

  run uninstall_apt_packages
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt remove -y htop git"* ]]
}

@test "uninstall_apt_packages: should show message when list is empty" {
  PACKAGES=()

  run uninstall_apt_packages
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"No packages defined to uninstall."* ]]
  [[ "$output" != *"sudo apt remove"* ]]
}
