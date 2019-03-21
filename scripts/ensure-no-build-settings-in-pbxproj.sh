#!/usr/bin/env bash

PROJECT_PATH=${1}
if [ -z "${PROJECT_PATH}" ]; then
  echo "Project path not specified."
  exit 1
fi

PROJECT_FILE_PATH="${PROJECT_PATH}/project.pbxproj"
NUMBER_OF_BUILD_SETTINGS=`grep "buildSettings" "$PROJECT_FILE_PATH" | wc -l`
NUMBER_OF_EMPTY_BUILD_SETTINGS=`grep -B 0 -A 1 "buildSettings" "$PROJECT_FILE_PATH" | grep "};" | wc -l`

if [ $NUMBER_OF_BUILD_SETTINGS != $NUMBER_OF_EMPTY_BUILD_SETTINGS ]; then
  NUMBER_WITH_SETTINGS=`expr $NUMBER_OF_BUILD_SETTINGS - $NUMBER_OF_EMPTY_BUILD_SETTINGS`

  echo "${PROJECT_PATH}: error: Found ${NUMBER_WITH_SETTINGS} build settings in Xcode project file. Build settings should only be defined in .xcconfig files."
  exit 1
fi
