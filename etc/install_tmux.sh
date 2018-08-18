#!/bin/bash
#
# Install tmux

set -Ceu -o pipefail

if type tmux >/dev/null 2>&1; then
  sudo apt remove -y tmux
fi

sudo apt install -y libevent-dev libncurses5-dev

cd $HOME/local/src

version=2.7
rel_page="https://github.com/tmux/tmux/releases"
pkg_name="tmux-${version}"
dl_url="${rel_page}/download/${version}/${pkg_name}.tar.gz"

wget -qO - ${dl_url} | tar xvfz -
cd ${pkg_name}
./configure --prefix=$HOME/local
make -j"$(nproc)"
make install

source ~/.bashrc
tmux -V
