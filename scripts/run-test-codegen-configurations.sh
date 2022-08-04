#!/bin/bash

cd $(dirname "$0")/../CodegenCLI

CodeGenConfigsDirectory="../Tests/TestCodeGenConfigurations"

for dir in `ls $CodeGenConfigsDirectory`;
do
  `swift run apollo-ios-cli generate -p $CodeGenConfigsDirectory/$dir/apollo-codegen-config.json`
done
