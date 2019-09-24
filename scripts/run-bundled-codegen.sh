#!/usr/bin/env bash

# Exit on all errors, undeclared variables and pipefailures.
set -euo pipefail

# Get the path to the script directory
SCRIPT_DIR="$(dirname "$0")"

# Get the SHASUM of the tarball
ZIP_FILE="${SCRIPT_DIR}/apollo.tar.gz"
SHASUM="$(/usr/bin/shasum -a 256 "${ZIP_FILE}")"
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
  EXPECTED_SHASUM="13febaa462e56679099d81502d530e16c3ddf1c6c2db06abe3822c0ef79fb9d2  ${ZIP_FILE}"

  if [ "${SHASUM}" == "${EXPECTED_SHASUM}" ]; then
    echo "Correct version of the CLI tarball is included, checking if it's already been extracted..."
  else
    echo "Error: The SHASUM of this zip file does not match the official released version from Apollo! This may present security issues. Terminating code generation." >&2
    exit 1
  fi

  # Check if the SHASUM file has already been written for this version
  if [ -f "${SHASUM_FILE}" ]; then
    # The file exists, let's see if it's the same SHASUM
    FILE_CONTENTS="$(cat "${SHASUM_FILE}")"
    if [ "${FILE_CONTENTS}" == "${SHASUM}" ]; then
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

# Use the bundled executable of the Apollo CLI to generate code
APOLLO_CLI="${SCRIPT_DIR}/apollo/bin/run"

# Print version
echo "Apollo CLI Information: $("${APOLLO_CLI}" --version)"

# Print commands before executing them (useful for troubleshooting)
set -x
"$APOLLO_CLI" "$@"
