#!/bin/bash
#
# Setup Ubuntu(18.04) Environment

set -Ceu -o pipefail

umask 022

script_dir="$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)"
source $script_dir/util/include.sh
#source ${script_dir:-$(cd $(dirname ${BASH_SOURCE}) && pwd)}/util/include.sh

cd

info "Change Ubuntu settings for Japanese..."

sudo sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -
sudo wget https://www.ubuntulinux.jp/sources.list.d/bionic.list -O /etc/apt/sources.list.d/ubuntu-ja.list

sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
sudo apt update && sudo apt upgrade -y
mkdir -p local/src

#info "Backup ~/.* and /etc/* files and package list to ~/backup/*..."
info "Backup package list to ~/backup/first_time/*..."

mkdir -p backup/first_time
# sudo cp -rp .* /etc/* backup/first_time
dpkg --get-selections > backup/first_time/dpkg-get-selections
dpkg -l > backup/first_time/dpkg-list

info "Install latest git..."

sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git
git --version

packagelist=(
  "build-essential"
  "automake"
  "xsel"
  "shellcheck"
)

info "Install packages..."
for list in "${packagelist[@]}"
do
  sudo apt install -y $list
done

info "Setup SSH and GnuPG settings..."
ssh -V
echo
gpg --version
echo
gpg-agent --version
mkdir -p ~/.ssh ~/.gnupg
chmod 700 ~/.ssh
chmod 700 ~/.gnupg
info "Please create key according to next command."
info "ssh-keygen -t ed25519 -C <YOUR_GITHUB_EMAIL> -f id_ed25519_github"
info "Copy public key content to clipboard like next command."
info "cat id_ed25519_github | xsel -bi"
info "Resister to GitHub SSH Key setting."
info "Run connection test to GitHub with SSH."
info "ssh -T git@github.com"
info "Bitbucket can also be set in the same way."

# Deploy
source $script_dir/link.sh

info "Install anyenv and *envs"
source $dot_dir/etc/install/install_envs.sh

#if ! has nvim; then
#  echo
#  info "Neovim is not installed yet. installing..."
#  source $dot_dir/etc/install/install_neovim.sh
#  info "Installed Neovim."
#fi
