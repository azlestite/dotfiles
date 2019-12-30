#!/bin/bash
#
# Install cmake

set -Ceu -o pipefail

cd $HOME/local/src
version=3.16
build=1
pkg=cmake-${version}.${build}
wget -qO - https://cmake.org/files/v${version}/${pkg}.tar.gz | tar xvfz -
cd ${pkg}
./configure --prefix=$HOME/local
make -j4
make install
