#!/bin/bash
#
# Include utility files

set -Ceu -o pipefail

set +u
if [ -n "${INCLUDE_GUARD}" ]; then
  set -u
  return
else
  set -u
  readonly INCLUDE_GUARD=1
fi

util_dir=$(cd $(dirname ${BASH_SOURCE}) && pwd)

source ${util_dir}/color_output.sh
source ${util_dir}/func.sh
