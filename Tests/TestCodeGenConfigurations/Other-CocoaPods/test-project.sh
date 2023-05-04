#!/bin/bash

pod install
set -o pipefail && xcodebuild test -workspace CocoaPodsProject.xcworkspace -scheme CocoaPodsProject -destination platform=macOS -quiet | xcbeautify --is-ci
