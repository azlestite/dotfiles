#!/bin/bash
#
# Install python, nodejs, and go

set -Ceu -o pipefail

echo "--------- Python for NeoVim -----------------------"
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev
pyenv --version
#pyenv install -l
python2_latest=$(pyenv install -l | grep -v '[a-z]' | grep '2.7.[0-9]*' | tail -1 | sed 's/\s//g')
python3_latest=$(pyenv install -l | grep -v '[a-z]' | tail -1 | sed 's/\s//g')
echo "Install python ${python2_latest}..."    
pyenv install $python2_latest
echo "Install python ${python3_latest}..."    
pyenv install $python3_latest
pyenv rehash
pyenv global $python2_latest
pyenv which python
pip install pynvim
pyenv global $python3_latest
pyenv which python
python --version
pip install --upgrade pip
pip install pipenv pynvim
echo "--------- END --------------------------"

#echo "--------- Node.js ----------------------"
#nodenv --version
#nodenv install -l
#node_latest=$(nodenv install -l | grep '^\s*[0-9].*' | tail -1 | sed 's/\s//g')
#nodenv install $node_latest
#nodenv global $node_latest
#nodenv rehash
#node -v
#npm -v
#echo "--------- END --------------------------"

#echo "--------- Go ----------------------"
#goenv --version
#goenv install -l
#go_latest=$(goenv install -l | grep -v '[a-z]' | tail -1 | sed 's/\s//g')
#goenv install $go_latest
#goenv global $go_latest
#goenv rehash
#go version
#echo "--------- END --------------------------"

#exec $SHELL -l
#source ~/.profile
