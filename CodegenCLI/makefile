.PHONY: clean wipe build build-for-cocoapods test

default: clean build

clean: 
	swift package clean

wipe: 
	rm -rf .build

build: 
	swift build -c release

build-for-cocoapods:
	swift build -c release -Xswiftc -DCOCOAPODS

test: 
	swift test
