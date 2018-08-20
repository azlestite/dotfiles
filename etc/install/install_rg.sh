#!/bin/bash
#
# Install rg(ripgrep)

set -Ceu -o pipefail

version=0.9.0
rel_page="https://github.com/BurntSushi/ripgrep/releases"
pkg_name="ripgrep_${version}_amd64.deb"
dl_url="${rel_page}/download/${version}/${pkg_name}"

cd $HOME/local/src
curl -LO ${dl_url}
sudo dpkg -i ${pkg_name}
