#!/usr/bin/env bash
#
# @file scripts/generate_docs.sh
# @brief Generate Markdown documentation from shell scripts in the `install/` directory.
# @description This script uses `shdoc` to extract documentation comments from shell scripts and
#   generates Markdown files in the `docs/reference/` directory.
#   It also creates an index page linking to all generated reference pages.

set -Eeuo pipefail

# Always work from the project root
cd "$(dirname "$0")/.."

readonly DOCS_DIR="docs"
readonly REFERENCE_DIR="${DOCS_DIR}/reference"
readonly INDEX_FILE="${DOCS_DIR}/index.md"

# @description Remove stale generated docs before a new generation pass.
function clean_generated_docs() {
  echo "Cleaning old documentation..."
  rm -rf "${REFERENCE_DIR}"
  # rm -f "${LANDING_PAGE}" "${CATALOG_PAGE}"
  # sleep 3
  mkdir -p "${REFERENCE_DIR}"
}

# @description Generate Markdown documentation for all shell scripts under `install/`.
function generate_pages() {
  if ! command -v shdoc &>/dev/null; then
    echo "Error: shdoc is not installed."
    echo "Please install it from: https://github.com/reconquest/shdoc"
    exit 1
  fi

  echo "Generating documentation from shell scripts..."

  # Initialize Index file in docs/
  {
    echo "# Project Documentation"
    echo ""
    echo "This page serves as an entry point for the auto-generated API reference."
    echo ""
    echo "## API Reference"
    echo ""
  } >"${INDEX_FILE}"

  # Find and process shell scripts
  find install -name "*.sh" | sort | while read -r file; do
    rel_path="${file#./}"
    out_name="${rel_path//\//_}"
    out_name="${out_name%.sh}.md"

    # Generate the Markdown content
    local content
    content=$(shdoc <"${file}")

    if [[ -n "${content}" ]]; then
      echo "Processing: ${file}"
      {
        echo "# Reference: ${file}"
        echo ""
        echo "${content}"
      } >"${REFERENCE_DIR}/${out_name}"

      # Add to Index (linking from docs/index.md to reference/*.md)
      echo "* [${file}](reference/${out_name})" >>"${INDEX_FILE}"
    else
      echo "Skip: ${file} (No documentation comments)"
    fi
  done

  echo "Success! Documentation index created at ${INDEX_FILE}"
}

# @description Regenerate every public docs page under `docs/`.
function main() {
  clean_generated_docs
  generate_pages
}

main
