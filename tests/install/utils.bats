#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

readonly SCRIPT_PATH="./install/utils.sh"

function dump_output() {
  echo -e "\n--- DEBUG EXECUTION LOG (Test: ${BATS_TEST_DESCRIPTION}) ---" >&3
  echo "$output" >&3
  echo -e "-----------------------------------------------------------\n" >&3
}

function setup() {
  source "${SCRIPT_PATH}"
}

@test "validation: script file should exist" {
  [ -f "${SCRIPT_PATH}" ]
}

# --- Logging Tests ---

@test "logging: info should output to stdout with INFO prefix" {
  run --separate-stderr info "info message"
  # dump_output
  [ "$status" -eq 0 ]
  [[ "$output" == *"INFO info message"* ]]
  [ "$stderr" = "" ]
}

@test "logging: warn should output to stdout with WARN prefix" {
  run --separate-stderr warn "warn message"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARN warn message"* ]]
  [ "$stderr" = "" ]
}

@test "logging: error should output to stderr with ERROR prefix" {
  run --separate-stderr error "error message"
  # dump_output
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"ERROR error message"* ]]
  [ "$output" = "" ]
}

# --- OS Detection Tests ---

@test "os_type: should detect darwin on macOS" {
  # uname をモック
  function uname() { echo "Darwin"; }
  export -f uname

  run os_type
  # dump_output
  [ "$status" -eq 0 ]
  [ "$output" = "darwin" ]
}

@test "os_type: should detect ubuntu from /etc/os-release" {
    # Linux環境をシミュレート
    function uname() { echo "Linux"; }
    export -f uname

    local mock_os_release=$(mktemp)
    echo 'ID=ubuntu' > "$mock_os_release"

    # テスト時のみ参照パスをモックに向ける（utils.sh側にOS_RELEASE_PATH定義が必要）
    OS_RELEASE_PATH="$mock_os_release" run os_type
    # dump_output
    [ "$status" -eq 0 ]
    [ "$output" = "ubuntu" ]

    rm -f "$mock_os_release"
}

@test "os_type: should return linux (fallback) when /etc/os-release is missing" {
  function uname() { echo "Linux"; }
  export -f uname

  # 存在しないパスを指定して fallback ルートをテスト
  OS_RELEASE_PATH="/dev/null" run os_type
  [ "$output" = "linux" ]
}

@test "os_type: should detect windows on MINGW/Git Bash" {
    # Windows上のGit Bash環境をシミュレート
    # スクリプト側が uname -s を見ているので、引数に対応させる
    function uname() {
        if [[ "$1" == "-s" ]]; then
            echo "MINGW64_NT-10.0-19045"
        else
            echo "Windows_NT"
        fi
    }
    export -f uname

    run os_type
    # dump_output
    [ "$status" -eq 0 ]
    [ "$output" = "windows" ]
}

@test "os_type: should return unknown for unsupported OS" {
    function uname() { echo "FreeBSD"; }
    export -f uname

    run os_type
    # dump_output
    [ "$status" -eq 0 ]
    [ "$output" = "unknown" ]
}


# --- WSL Detection Tests ---

@test "is_wsl: should return 0 (true) when uname -r contains Microsoft" {
  function uname() {
    if [[ "$1" == "-r" ]]; then
      echo "5.15.0-microsoft-standard-WSL2"
    else
      command uname "$@"
    fi
  }
  export -f uname

  run is_wsl
  [ "$status" -eq 0 ]
}

@test "is_wsl: should return 1 (false) on standard Linux" {
  function uname() {
    if [[ "$1" == "-r" ]]; then
      echo "5.15.0-generic"
    else
      command uname "$@"
    fi
  }
  export -f uname

  run is_wsl
  [ "$status" -eq 1 ]
}

# --- OS Bit Tests ---

@test "os_bit: should return machine architecture" {
  function uname() {
    if [[ "$1" == "-m" ]]; then
      echo "x86_64"
    fi
  }
  export -f uname

  run os_bit
  [ "$status" -eq 0 ]
  [ "$output" = "x86_64" ]
}
