#!/bin/bash

CURRENT_VERSION=$($(dirname "$0")/get-version.sh)

# Set configuration file version constant

source "$(dirname "$0")/version-constants.sh"

NEW_VERSION="$1"

 if [[ ! $NEW_VERSION =~ ^[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2} ]]; then
     echo "You must specify a version in the format x.x.x"
     exit 1
 fi

echo "$VERSION_CONFIG_VAR = $NEW_VERSION" > $VERSION_CONFIG_FILE

# Set CLI version constant

MATCH_TEXT='CLIVersion: String = "'
SEARCH_TEXT="$MATCH_TEXT$CURRENT_VERSION"
REPLACE_TEXT="$MATCH_TEXT$NEW_VERSION"
sed -i '' -e "s/$SEARCH_TEXT/$REPLACE_TEXT/" $CLI_CONSTANTS_FILE

# Feedback
echo "Committing change from version $CURRENT_VERSION to $NEW_VERSION"
git add -A && git commit -m "Updated version numbers"
