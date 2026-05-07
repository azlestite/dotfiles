#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/docker.sh"

# load "${SCRIPT_PATH}"

# デバッグ用関数
function dump_output() {
  # $output の前に改行を入れ、区切り線で囲む
  echo -e "\n--- DEBUG EXECUTION LOG (Test: ${BATS_TEST_DESCRIPTION}) ---" >&3
  echo "$output" >&3
  echo -e "-----------------------------------------------------------\n" >&3
}

function setup() {
  # 必要なコマンドをモック
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
  function install() { echo "install $*"; }
  export -f install
  function curl() { echo "curl $*"; }
  export -f curl
  function chmod() { echo "chmod $*"; }
  export -f chmod

  function tee() {
    echo "tee_target: $1"
    cat -
  }
  export -f tee

  function groupadd() { echo "groupadd $*"; }
  export -f groupadd
  function usermod() { echo "usermod $*"; }
  export -f usermod

  source "${SCRIPT_PATH}"
}

@test "validation: script file should exist" {
  [ -f "${SCRIPT_PATH}" ]
}

@test "validation: script file should be executable" {
  [ -x "${SCRIPT_PATH}" ]
}

@test "uninstall_old_docker: should remove specific packages when they are installed" {
  function dpkg() {
    # 今回のロジックでは "${remove_packages[@]}" が引数として渡される
    # そのうち docker.io だけが存在するというシナリオを想定
    echo -e "docker.io\tinstall"
  }
  export -f dpkg

  run uninstall_old_docker
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt remove -y docker.io"* ]]
}

@test "uninstall_old_docker: should remove multiple packages separated by spaces" {
  function dpkg() {
    echo -e "docker.io\tinstall"
    echo -e "containerd\tinstall"
  }
  export -f dpkg

  run uninstall_old_docker
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt remove -y docker.io containerd"* ]]
}

@test "uninstall_old_docker: should skip when no legacy packages are found" {
  # パッケージが見つからない場合、dpkg は標準エラー出力にメッセージを出し、
  # 標準出力には何も出さない(またはエラーを返す)
  function dpkg() {
    return 1
  }
  export -f dpkg

  run uninstall_old_docker
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"No legacy packages found. Skipping uninstall."* ]]
  # apt remove が呼ばれていないことを確認
  [[ "$output" != *"sudo apt remove"* ]]
}

@test "setup_repository: should execute the full sequence from GPG setup to repo creation" {
  # 必要に応じてOS情報をセット
  export UBUNTU_CODENAME="noble"

  run setup_repository
  # dump_output

  [ "$status" -eq 0 ]
  # keyringsディレクトリの作成と権限設定
  [[ "$output" == *"sudo install -m 0755 -d /etc/apt/keyrings"* ]]
  # GPGキーのダウンロード(URLの検証)
  [[ "$output" == *"sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg"* ]]
  # キーファイルの権限設定
  [[ "$output" == *"sudo chmod a+r /etc/apt/keyrings/docker.asc"* ]]
  # sources.list の内容検証(ファイル名と中身の重要項目)
  [[ "$output" == *"sudo tee_target: /etc/apt/sources.list.d/docker.sources"* ]]
  [[ "$output" == *"URIs: https://download.docker.com/linux/ubuntu"* ]]
  [[ "$output" == *"Suites: noble"* ]]
  [[ "$output" == *"Signed-By: /etc/apt/keyrings/docker.asc"* ]]
}

@test "install_docker_engine: should install packages and configure docker group" {
  # テスト用の環境変数
  export USER="testuser"

  run install_docker_engine
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt install -y docker-ce docker-ce-cli"* ]]
  [[ "$output" == *"sudo groupadd -f docker"* ]]
  [[ "$output" == *"sudo usermod -aG docker testuser"* ]]
}

@test "uninstall_docker_engine: should remove all configured docker engine packages" {
  run uninstall_docker_engine
  # dump_output

  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"* ]]
}
