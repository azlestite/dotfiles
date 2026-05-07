#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/os_config.sh"

function dump_output() {
  echo -e "\n--- DEBUG EXECUTION LOG (Test: ${BATS_TEST_DESCRIPTION}) ---" >&3
  echo "$output" >&3
  echo -e "-----------------------------------------------------------\n" >&3
}

function setup() {
  # sudo のモックを改良
  # 引数をそのまま "$@" で渡すことでクォートを維持します
  function sudo() {
    if [[ "$1" == "sed" ]]; then
      local cmd="$1"
      shift
      # ファイル書き換え自体は静かに実行
      command "$cmd" "$@" >/dev/null 2>&1
      # テスト検証用のログには本来のコマンドラインを再現して出力
      echo "sudo $cmd $*"
    else
      echo "sudo $*"
    fi
  }
  export -f sudo

  # 各OSコマンドのモック（実行されないようにする）
  function locale-gen() { echo "locale-gen $*"; }
  function localectl() { echo "localectl $*"; }
  function timedatectl() { echo "timedatectl $*"; }
  export -f locale-gen localectl timedatectl

  source "${SCRIPT_PATH}"
}

function teardown() {
  if [ -n "${temp_file:-}" ] && [ -f "${temp_file}" ]; then
    rm -f "${temp_file}" "${temp_file}.bak"
  fi
}

@test "validation: script file should exist and be executable" {
  [ -f "${SCRIPT_PATH}" ]
  [ -x "${SCRIPT_PATH}" ]
}

@test "setup_locale: should generate en_US.UTF-8 and set it as default" {
  run setup_locale
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo locale-gen en_US.UTF-8"* ]]
  [[ "$output" == *"sudo localectl set-locale LANG=en_US.UTF-8"* ]]
}

@test "setup_timezone: should set timezone to Asia/Tokyo" {
  run setup_timezone
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo timedatectl set-timezone Asia/Tokyo"* ]]
}

@test "setup_repositories: should correctly replace archive.ubuntu.com with mirror URL" {
  temp_file=$(mktemp)

  tee "${temp_file}" <<EOF
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

  export APT_SOURCES_PATH="${temp_file}"
  run setup_repositories
  # dump_output

  [ "$status" -eq 0 ]

  local content=$(cat "$temp_file")
  [[ "$content" == *"https://ftp.udx.icscoe.jp/Linux/ubuntu/"* ]]
  [[ "$content" != *"http://archive.ubuntu.com"* ]]
  [[ "$content" == *"http://security.ubuntu.com/ubuntu/"* ]]
}

# @test "main: should execute all setup functions in order" {
#   # function info() { echo "MOCK_INFO: $*"; }
#   # export -f info

#   run main
#   dump_output

#   [ "$status" -eq 0 ]
#   [[ "$output" == *"Set OS configuration..."* ]]
#   [[ "$output" == *"sudo locale-gen en_US.UTF-8"* ]]
#   [[ "$output" == *"sudo localectl set-locale LANG=en_US.UTF-8"* ]]
#   [[ "$output" == *"sudo timedatectl set-timezone Asia/Tokyo"* ]]
# }
