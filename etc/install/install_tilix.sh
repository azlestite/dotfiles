#!/bin/bash
#
# Setup Tilix

set -Ceu -o pipefail

sudo add-apt-repository -y ppa:webupd8team/terminix
sudo apt update
sudo apt install -y tilix
# prevent "bash: /etc/profile.d/vte.sh: No such file or directory"
sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

# dbus-x11が無いとPreferenceを設定できなかった
sudo apt install -y dbus-x11 x11-xserver-utils

# fcitx-mozcのインストール
sudo apt install -y fcitx-mozc
# machine-idに生成したUUIDを書き込む
sudo sh -c "dbus-uuidgen > /var/lib/dbus/machine-id"

# Copy Myrica font from windows
sudo mkdir -p /usr/share/fonts/truetype/myrica
sudo cp /mnt/d/PTools/Fonts/Myrica*.ttf /usr/share/fonts/truetype/myrica/
sudo fc-cache -fv

# Download Molokai color scheme for Tilix
mkdir -p ~/.config/tilix/schemes
wget -qO $HOME"/.config/tilix/schemes/molokai.json" https://git.io/v7QVE

# Install GTK Theme
sudo add-apt-repository -y ppa:tista/adapta
sudo apt update -q
sudo apt install -y adapta-gtk-theme
