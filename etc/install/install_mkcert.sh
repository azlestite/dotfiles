#!/bin/bash
#
# Install mkcert

set -Ceu -o pipefail

sudo apt install libnss3-tools

go get -u github.com/FiloSottile/mkcert
$(go env GOPATH)/bin/mkcert
