#!/bin/bash
#
# Setup Tilix Terminal

set -Ceu -o pipefail

# Tilix
sudo add-apt-repository -y ppa:webupd8team/terminix
sudo apt update -qq
sudo apt install -y tilix dbus-x11 x11-xserver-utils
# prevent "bash: /etc/profile.d/vte.sh: No such file or directory"
sudo ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh

# Fcitx and Mozc
sudo apt install -y fcitx-mozc
# write UUID to machine-id
sudo sh -c "dbus-uuidgen > /var/lib/dbus/machine-id"

# Myrica font
sudo mkdir -p /usr/share/fonts/truetype/myrica
sudo cp /mnt/d/PTools/Fonts/Myrica*.ttf /usr/share/fonts/truetype/myrica/
sudo fc-cache -fv

# Molokai color scheme for Tilix
mkdir -p ~/.config/tilix/schemes
wget -qO $HOME"/.config/tilix/schemes/molokai.json" https://git.io/v7QVE

# Install Adapta GTK Theme
sudo add-apt-repository -y ppa:tista/adapta
sudo apt update -qq
sudo apt install -y adapta-gtk-theme
