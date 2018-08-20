#!/bin/bash
#
# Install gibo

set -Ceu -o pipefail

mkdir -p $HOME/bin
curl -L https://raw.github.com/simonwhitaker/gibo/master/gibo \
  -so ~/bin/gibo && chmod +x ~/bin/gibo && gibo update
