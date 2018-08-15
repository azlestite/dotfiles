#!/bin/bash
#
# Install Tig(text-mode interface for Git) with wide character support

set -Ceu -o pipefail

inst_dir=$HOME/local

sudo apt -y install asciidoc libncursesw5-dev

if type ghq fzf >/dev/null 2>&1; then
  ghq get jonas/tig
  cd $(ghq root)/$(ghq list | fzf --select-1 --query="jonas/tig")
else
  cd ${inst_dir}/src
  git clone https://github.com/jonas/tig
  cd tig
fi

LDLIBS=-lncursesw CPPFLAGS=-DHAVE_NCURSESW_CURSES_H make
make install prefix="${inst_dir}"
make install-release-doc prefix="${inst_dir}"
tig --version
