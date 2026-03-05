#!/usr/bin/env bash

# exit immediately if password-manager-binary is already in $PATH
type bitwarden >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
    # commands to install password-manager-binary on Linux
    echo "Install Bitwarden CLI..."
    if [ "$(uname -m)" = "x86_64" ]; then
        version=2026.1.0
        curl -Lo $HOME/.local/src/bw-linux.zip https://github.com/bitwarden/clients/releases/download/cli-v${version}/bw-linux-${version}.zip
        unzip $HOME/.local/src/bw-linux.zip -d $HOME/.local/bin/
        chmod +x $HOME/.local/bin/bw
        # rm -rf $HOME/.local/src/bw-linux.zip
    fi
    ;;
Darwin)
    # commands to install password-manager-binary on Darwin
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
