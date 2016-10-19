#!/bin/bash

NEW_VERSION="$1"

 if [[ -z "NEW_VERSION" ]]; then
     echo "You must specify a version."
     exit 1
 fi

xcrun agvtool new-version $NEW_VERSION &> /dev/null
xcrun agvtool new-marketing-version $NEW_VERSION &> /dev/null

git add -A && git commit -m "$NEW_VERSION"
git tag "$NEW_VERSION"
