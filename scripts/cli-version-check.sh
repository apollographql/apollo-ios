#!/bin/bash

directory=$(dirname "$0")
projectDir="$directory/../CLI"

APOLLO_VERSION=$(sh "$directory/get-version.sh")
FILE_PATH="$projectDir/apollo-ios-cli.tar.gz"
tar -xf "$FILE_PATH"
CLI_VERSION=$(./apollo-ios-cli --version)

echo "Comparing Apollo version $APOLLO_VERSION with CLI version $CLI_VERSION"

if [ "$APOLLO_VERSION" = "$CLI_VERSION" ]; then
  echo "Success - matched!"
else
  echo "Failed - mismatch!"
  exit 1
fi
