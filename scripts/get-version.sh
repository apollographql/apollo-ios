#!/bin/bash

source "$(dirname "$0")/version-constants.sh"

prefix="$VERSION_CONFIG_VAR = "
version_config=$(cat $VERSION_CONFIG_FILE)
echo ${version_config:${#prefix}}
