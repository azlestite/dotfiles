#!/bin/bash
#
# Install Docker
# WSL doesn't support MS_SLAVE yet, so docker after 17.09.1 get error.

set -Ceu -o pipefail

cd $HOME/local/src
curl -O https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.09.0~ce-0~debian_amd64.deb
sudo dpkg -i docker-ce_17.09.0~ce-0~debian_amd64.deb
sudo cgroupfs-mount
sudo usermod -aG docker $USER
sudo service docker start
echo "Run WSL as administrator and run next command."
echo "sudo cgroupfs-mount && sudo service docker start"
