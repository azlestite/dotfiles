#!/bin/bash
#
# Install anyenv and *envs

set -Ceu -o pipefail

echo "--------- anyenv -----------------------"
git clone https://github.com/riywo/anyenv $HOME/.anyenv
exec $SHELL -l

any_root="$(anyenv root)"
mkdir -p ${any_root}/plugins
git clone https://github.com/znz/anyenv-update.git ${any_root}/plugins/anyenv-update
git clone https://github.com/znz/anyenv-git.git ${any_root}/plugins/anyenv-git
echo "--------- END --------------------------"

echo "--------- *envs ------------------------"
anyenv install pyenv
anyenv install nodenv
anyenv install goenv

exec $SHELL -l
echo "--------- END --------------------------"

source ./install_langs.sh
