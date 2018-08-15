#!/bin/bash
#
# Install ag(Silver Searcher)

set -Ceu -o pipefail

sudo apt install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev

cd $HOME/local/src
git clone https://github.com/ggreer/the_silver_searcher.git
cd the_silver_searcher
./build.sh --prefix=$HOME/local
make install
