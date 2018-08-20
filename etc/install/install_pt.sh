#!/bin/bash
#
# Install pt(Platinum Searcher)

set -Ceu -o pipefail

version=2.1.6
rel_page="https://github.com/monochromegane/the_platinum_searcher/releases"
pkg_name="pt_linux_amd64"
dl_url="${rel_page}/download/v${version}/${pkg_name}.tar.gz"

cd $HOME/local/src
wget -qO - ${dl_url} | tar xvfz -
cd ${pkg_name}
mv pt $HOME/local/bin/
