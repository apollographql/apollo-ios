#!/bin/bash

cd $(dirname "$0")/../SwiftScripts

swift run Codegen --package-type SPM
