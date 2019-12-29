#!/bin/bash
#
# Install anyenv and *envs

set -Ceu -o pipefail

script_dir="$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)"
#anyenv_bin=$HOME/.anyenv/bin/anyenv

echo "--------- anyenv -----------------------"
git clone https://github.com/anyenv/anyenv $HOME/.anyenv
#exec $SHELL -l
source ~/.profile # .bashrc内部でanyenv init -は実行される。
#eval "$($any_bin init -)"
#echo y | $anyenv_bin install --init
echo y | anyenv install --init

any_root="$(anyenv root)"
#any_root="$($anyenv_bin root)"
mkdir -p ${any_root}/plugins
git clone https://github.com/znz/anyenv-update.git ${any_root}/plugins/anyenv-update
git clone https://github.com/znz/anyenv-git.git ${any_root}/plugins/anyenv-git
echo "--------- END --------------------------"

echo "--------- *envs ------------------------"
#$anyenv_bin install pyenv
anyenv install pyenv
source ~/.profile
eval "$(pyenv init -)"
#anyenv install nodenv
#anyenv install goenv

#exec $SHELL -l
#source ~/.profile
echo "--------- END --------------------------"

#source ./etc/install/install_langs.sh
source $script_dir/install_langs.sh
