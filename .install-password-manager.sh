#!/usr/bin/env bash

set -Ceuo pipefail

# exit immediately if password-manager-binary is already in $PATH
type bw >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
    # commands to install password-manager-binary on Linux
    echo "Install Bitwarden CLI..."
    if [ "$(uname -m)" = "x86_64" ]; then
        sudo apt install -y unzip
        mkdir -p $HOME/.local/{bin,src}
        curl -fsSL "https://bitwarden.com/download/?app=cli&platform=linux" -o $HOME/.local/src/bw-linux.zip
        unzip $HOME/.local/src/bw-linux.zip -d $HOME/.local/bin/
        chmod +x $HOME/.local/bin/bw
        rm -rf $HOME/.local/src/bw-linux.zip
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
