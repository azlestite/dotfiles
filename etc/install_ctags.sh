#!/bin/bash
#
# Install universal-ctags

set -Ceu -o pipefail

sudo apt -y install python-docutils
cd $HOME/local/src
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure --prefix=$HOME/local --enable-iconv
make
make install

if [ ! -d "$HOME"/.ctags.d ]; then
  mkdir "$HOME"/.ctags.d

  cat <<-_EOT_ >"$HOME"/.ctags.d/config.ctags
	--recurse=yes
	--exclude=.git
	_EOT_
fi
