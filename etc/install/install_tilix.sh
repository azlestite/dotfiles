#!/bin/bash
#
# Setup Tilix

set -Ceu -o pipefail

sudo add-apt-repository -y ppa:webupd8team/terminix
sudo apt update
sudo apt install tilix

# dbus-x11が無いとPreferenceを設定できなかった
sudo apt install dbus-x11

# copy Myrica font from windows
sudo mkdir -p /usr/share/fonts/truetype/myrica
sudo cp /mnt/c/Windows/Fonts/Myrica* /usr/share/fonts/truetype/myrica/
sudo fc-cache -fv

# TilixのカラースキームをMolokaiにするためダウンロード
wget -qO $HOME"/.config/tilix/schemes/molokai.json" https://git.io/v7QVE

# fcitx-mozcのインストール
sudo apt install fcitx-mozc
# machine-idに生成したUUIDを書き込む
sudo sh -c "dbus-uuidgen > /var/lib/dbus/machine-id"
