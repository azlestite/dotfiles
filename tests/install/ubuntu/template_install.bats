#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/template_install.sh"

function dump_output() {
  echo -e "\n--- DEBUG EXECUTION LOG (Test: ${BATS_TEST_DESCRIPTION}) ---" >&3
  echo "$output" >&3
  echo -e "-----------------------------------------------------------\n" >&3
}

function setup() {
  source "${SCRIPT_PATH}"
}

@test "validation: script file should exist and be executable" {
  [ -f "${SCRIPT_PATH}" ]
  [ -x "${SCRIPT_PATH}" ]
}
