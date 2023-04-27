#!/bin/bash

set -o pipefail && xcodebuild test -scheme SPMInXcodeProject -quiet | xcbeautify --is-ci
