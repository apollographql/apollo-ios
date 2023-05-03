#!/bin/bash

echo "Testing PackageOne.."
cd PackageOne
swift test

echo "Testing PackageTwo.."
cd ../PackageTwo
swift test
