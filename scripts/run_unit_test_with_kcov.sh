#!/usr/bin/env bash
#

set -Eeuo pipefail

readonly COVERAGE_DIR="coverage"

function run_test_with_kcov() {
  kcov --clean --cobertura-only --include-path=install/ coverage/ bats -r tests/install/ubuntu/
}

function main() {
  cd "$(dirname "$0")/.."
  mkdir -p "${COVERAGE_DIR}"
  run_test_with_kcov
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
