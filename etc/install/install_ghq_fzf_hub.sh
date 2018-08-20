#!/bin/bash
#
# Install ghq, fzf, and hub

set -Ceu -o pipefail

go get github.com/motemen/ghq
ghq --version
go get github.com/github/hub
ghq get junegunn/fzf
cd $GOPATH/src/github.com/junegunn/fzf
printf "y\ny\nn\n" | ./install
source $HOME/.bashrc
fzf --version
fzf-tmux --version
