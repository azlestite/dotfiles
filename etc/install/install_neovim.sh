#!/bin/bash
#
# Install Neovim

set -Ceu -o pipefail

sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update -qq
sudo apt install -y neovim
nvim --version

# for python modules
sudo apt install -y python-dev python-pip python3-dev python3-pip
# for cpsm
sudo apt install cmake libboost-all-dev libicu-dev
