#!/bin/bash

directory=$(dirname "$0")
source "$directory/version-constants.sh"

constantsFile=$(cat $directory/../$APOLLO_CONSTANTS_FILE)
currentVersion=$(echo $constantsFile | sed 's/^.*ApolloVersion: String = "\([^"]*\).*/\1/')
echo $currentVersion
