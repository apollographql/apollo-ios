#!/bin/bash

test_projects=false

while getopts 't' OPTION; do
  case "$OPTION" in
    t)
      echo "[-t] used - each configuration will be tested"
      echo
      test_projects=true
      ;;
    ?)
      echo "script usage: $(basename  $0) [-t]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

cd $(dirname "$0")/../
CodeGenConfigsDirectory="./Tests/TestCodeGenConfigurations"

for dir in `ls $CodeGenConfigsDirectory`;
do
  echo "-- Generating code for project: $dir --"
  if swift run apollo-ios-cli generate -p $CodeGenConfigsDirectory/$dir/apollo-codegen-config.json; then
    if [ "$test_projects" = true ]; then
      echo -e "-- Testing project: $dir --"
      cd $CodeGenConfigsDirectory/$dir

      if /bin/bash ./test-project.sh; then
        echo -e "\n"
        cd - > /dev/null
      else
        exit 1
      fi
    fi
  else
    exit 1
  fi

  
done
