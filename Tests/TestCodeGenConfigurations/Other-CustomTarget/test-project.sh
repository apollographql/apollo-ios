#!/bin/bash

set -o pipefail && xcodebuild test -scheme CustomTargetProject -destination platform=macOS -quiet | xcbeautify --is-ci
