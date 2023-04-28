#!/bin/bash

pod install
set -o pipefail && xcodebuild test -workspace CocoaPodsProject.xcworkspace -scheme CocoaPodsProject -quiet | xcbeautify --is-ci
