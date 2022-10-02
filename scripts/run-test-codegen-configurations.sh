#!/bin/bash

cd $(dirname "$0")/../Sources/CodegenCLI

CodeGenConfigsDirectory="../../Tests/TestCodeGenConfigurations"

for dir in `ls $CodeGenConfigsDirectory`;
do
  echo $dir
  swift run apollo-ios-cli generate -p $CodeGenConfigsDirectory/$dir/apollo-codegen-config.json
done
