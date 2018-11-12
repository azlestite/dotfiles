#!/bin/bash
#
# Install jq

set -Ceu -o pipefail

version=1.6
rel_page="https://github.com/stedolan/jq/releases"
pkg_name="jq-linux64"
dl_url="${rel_page}/download/jq-${version}/${pkg_name}"

cd $HOME/local/bin
curl -o jq -L ${dl_url}
#wget ${dl_url} -qO jq
chmod +x jq
