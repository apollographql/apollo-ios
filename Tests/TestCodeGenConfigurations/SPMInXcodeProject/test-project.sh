#!/bin/bash

set -o pipefail && xcodebuild test -scheme SPMInXcodeProject -destination platform=macOS -quiet | xcbeautify --is-ci
