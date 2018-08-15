#!/bin/bash
#
# Install fd(alternative to find)

set -Ceu -o pipefail

version=7.0.0
rel_page="https://github.com/sharkdp/fd/releases"
pkg_name="fd_${version}_amd64.deb"
dl_url="${rel_page}/download/v${version}/${pkg_name}"

cd $HOME/local/src
wget -q ${dl_url}
sudo dpkg -i ${pkg_name}
