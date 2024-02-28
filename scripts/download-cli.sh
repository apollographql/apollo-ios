#!/bin/bash

# This script is intended for use only with the "InstallCLI" SPM plugin provided by Apollo iOS

directory=$(dirname "$0")
projectDir="$1"

if [ -z "$projectDir" ];
then
  echo "Missing project directory path." >&2
  exit 1
fi

APOLLO_VERSION=$(sh "$directory/get-version.sh")
DOWNLOAD_URL="https://www.github.com/apollographql/apollo-ios/releases/download/$APOLLO_VERSION/apollo-ios-cli.tar.gz"
FILE_PATH="$projectDir/apollo-ios-cli.tar.gz"
curl -L "$DOWNLOAD_URL" -s -o "$FILE_PATH"
#tar -xvf "$FILE_PATH"
#rm -f "$FILE_PATH"
