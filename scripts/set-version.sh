#!/bin/bash

source "$(dirname "$0")/version-constants.sh"

NEW_VERSION="$1"

 if [[ -z "NEW_VERSION" ]]; then
     echo "You must specify a version."
     exit 1
 fi

echo "$VERSION_CONFIG_VAR = $NEW_VERSION" > $VERSION_CONFIG_FILE

git add -A && git commit -m "$NEW_VERSION"
git tag "$NEW_VERSION"
