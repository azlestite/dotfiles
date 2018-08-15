#!/bin/bash
#
# Install Neovim

set -Ceu -o pipefail

sudo apt install -y software-properties-common
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update -q
sudo apt install -y neovim
nvim --version
sudo apt install -y python-dev python-pip python3-dev python3-pip

# cpsm
sudo apt install cmake libboost-all-dev libicu-dev
