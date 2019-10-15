#!/usr/bin/env bash

# Exit on all errors, undeclared variables and pipefailures.
set -euo pipefail

# Get the path to the script directory
SCRIPT_DIR="$(dirname "$0")"

# Get the SHASUM of the tarball
ZIP_FILE="${SCRIPT_DIR}/apollo.tar.gz"
SHASUM="$(/usr/bin/shasum -a 256 "${ZIP_FILE}" | /usr/bin/awk '{ print $1 }')"
SHASUM_FILE="${SCRIPT_DIR}/apollo/.shasum"
APOLLO_DIR="${SCRIPT_DIR}"/apollo

# Helper functions
remove_existing_apollo() {
  rm -r "${APOLLO_DIR}"
}

extract_cli() {
  tar xzf "${SCRIPT_DIR}"/apollo.tar.gz -C "${SCRIPT_DIR}"
  
  echo "${SHASUM}" | tee "${SHASUM_FILE}"
}

validate_codegen_and_extract_if_needed() {
  # Make sure the SHASUM matches the release for this version
  EXPECTED_SHASUM="0845089ac6fca8a910a317fdb90f2fe486d6e50f0a5caeb6e9c779c839188798"

  if [[ ${SHASUM} = ${EXPECTED_SHASUM}* ]]; then
    echo "Correct version of the CLI tarball is included, checking if it's already been extracted..."
  else
    echo "Error: The SHASUM of this zip file does not match the official released version from Apollo! This may present security issues. Terminating code generation." >&2
    exit 1
  fi

  # Check if the SHASUM file has already been written for this version
  if [ -f "${SHASUM_FILE}" ]; then
    # The file exists, let's see if it's the same SHASUM
    FILE_CONTENTS="$(cat "${SHASUM_FILE}")"
    if [[ ${FILE_CONTENTS} = ${EXPECTED_SHASUM}* ]]; then
      echo "Current verson of CLI is already extracted!"
    else
      echo "Extracting updated version of the Apollo CLI. This may take a minute..."
      remove_existing_apollo
      extract_cli
    fi
  else
    # The file doesn't exist, unzip the CLI
    echo "Extracting the Apollo CLI. This may take a minute..."
    extract_cli
  fi
}

# Make sure we're using an up-to-date and valid version of the Apollo CLI
validate_codegen_and_extract_if_needed

# Add the binary directory to the beginning of PATH so included binary verson of node is used.
PATH="${SCRIPT_DIR}/apollo/bin:${PATH}"

# Use the bundled executable of the Apollo CLI to generate code
APOLLO_CLI="${SCRIPT_DIR}/apollo/bin/run"

# Print version
echo "Apollo CLI Information: $("${APOLLO_CLI}" --version)"

# Print commands before executing them (useful for troubleshooting)
set -x
"$APOLLO_CLI" "$@"
