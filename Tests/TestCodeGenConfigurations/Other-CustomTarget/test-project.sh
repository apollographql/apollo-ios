#!/bin/bash

set -o pipefail && xcodebuild test -scheme CustomTargetProject -quiet | xcbeautify --is-ci
