#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/shdoc.sh"

function dump_output() {
  echo -e "\n--- DEBUG EXECUTION LOG (Test: ${BATS_TEST_DESCRIPTION}) ---" >&3
  echo "$output" >&3
  echo -e "-----------------------------------------------------------\n" >&3
}

function setup() {
  # 1. テスト専用の偽バイナリ設置先
  export MOCK_BIN_DIR="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "${MOCK_BIN_DIR}"
  export MOCK_SHDOC="${MOCK_BIN_DIR}/shdoc"

  function sudo() {
    echo "sudo $*"
    "$@"
  }

  function git() { echo "git $*"; }

  function make() {
    if [[ "$1" == "install" ]]; then
      touch "$MOCK_SHDOC"
      chmod +x "$MOCK_SHDOC"
    fi
  }

  # 2. command のモック: 外部環境の shdoc を完全に隠蔽する
  function command() {
    local cmd_type="$1"
    local target="$2"

    # command -v shdoc の場合のみ、MOCK_BIN_DIR を基準に判定
    if [[ "$cmd_type" == "-v" && "$target" == "shdoc" ]]; then
      if [[ -f "$MOCK_SHDOC" ]]; then
        echo "$MOCK_SHDOC"
        return 0
      fi
      return 1
    fi
    # それ以外（ls, rm, cd など）は本物の command を実行
    builtin command "$@"
  }

  export -f sudo git make command
  export MOCK_BIN_DIR MOCK_SHDOC

  source "${SCRIPT_PATH}"
}

@test "validation: script file should exist and be executable" {
  [ -f "${SCRIPT_PATH}" ]
  [ -x "${SCRIPT_PATH}" ]
}

@test "install_shdoc: should clone repository and installs the binary" {
  run install_shdoc
  dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"git clone --recursive"* ]]
  [[ "$output" == *"sudo make install"* ]]
  [ -f "$MOCK_SHDOC" ]
  [ -x "$MOCK_SHDOC" ]
}

@test "install_shdoc: should clean up the temporary directory" {
  # mktemp をモックしてディレクトリを追跡
  MOCK_TEMP_BASE="${BATS_TEST_TMPDIR}/work"
  mkdir -p "$MOCK_TEMP_BASE"

  function mktemp() {
    builtin command mktemp -d -p "$MOCK_TEMP_BASE"
  }
  export -f mktemp

  run install_shdoc
  dump_output
  [ "$status" -eq 0 ]

  # 作業ディレクトリが削除されている（中身が空）か確認
  [ -z "$(ls -A "$MOCK_TEMP_BASE")" ]
}

@test "main: should install shdoc if it is not present" {
  # 事前条件: shdoc が存在しない
  [ ! -f "$MOCK_SHDOC" ]

  run main
  dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"Install shdoc..."* ]]
  [[ "$output" == *"sudo make install"* ]]
  [ -f "$MOCK_SHDOC" ]
}

@test "main: should skip installation if shdoc is already present" {
  # 事前条件: すでに shdoc が存在する状態を作る
  touch "$MOCK_SHDOC"
  chmod +x "$MOCK_SHDOC"

  run main
  dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"shdoc is already installed."* ]]
  # インストール処理（git clone）が呼ばれていないことを確認
  [[ "$output" != *"git clone"* ]]
}

@test "uninstall_shdoc: should remove the binary if it exists" {
  # 1. 準備: あらかじめ shdoc バイナリが存在する状態にする
  touch "$MOCK_SHDOC"
  chmod +x "$MOCK_SHDOC"
  [ -f "$MOCK_SHDOC" ] # 存在する事を確認

  # 2. 実行
  run uninstall_shdoc
  dump_output

  # 3. 検証
  [ "$status" -eq 0 ]
  [[ "$output" == *"Removing shdoc from $MOCK_SHDOC"* ]]
  [[ "$output" == *"sudo rm -f $MOCK_SHDOC"* ]]

  # 実際にファイルが消えているか確認
  [ ! -f "$MOCK_SHDOC" ]
}

@test "uninstall_shdoc: should show warning if shdoc is not installed" {
  # 1. 準備: バイナリが存在しない状態（空のディレクトリ）
  [ ! -f "$MOCK_SHDOC" ]

  # 2. 実行
  run uninstall_shdoc
  dump_output

  # 3. 検証
  [ "$status" -eq 0 ]
  [[ "$output" == *"shdoc is not installed, nothing to remove."* ]]
  # sudo rm が呼ばれていないことを確認
  [[ "$output" != *"sudo rm -f"* ]]
}
