.PHONY: clean wipe build test

default: clean build

clean: 
	swift package clean

wipe: 
	rm -rf .build

build: 
	swift build -c release

test: 
	swift test
