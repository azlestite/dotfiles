#!/usr/bin/env bash

set -Ceuo pipefail

type bw >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
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
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
