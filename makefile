.PHONY: clean wipe build build-for-cocoapods test

default: clean build

clean:
	swift package clean

wipe:
	rm -rf .build

build:
	swift build -c release

build-cli:
	swift build --product apollo-ios-cli -c release; \
	cp -f .build/release/apollo-ios-cli apollo-ios-cli

build-cli-universal:
	swift build --product apollo-ios-cli -c release --arch arm64 --arch x86_64; \
	cp -f .build/apple/Products/Release/apollo-ios-cli apollo-ios-cli

build-cli-for-cocoapods:
	swift build --product apollo-ios-cli -c release -Xswiftc -DCOCOAPODS

archive-cli-for-release:
	make build-cli-universal; \
	tar -czf apollo-ios-cli.tar.gz apollo-ios-cli; \
	echo "Attach apollo-ios-cli.tar.gz to the GitHub release"

test: 
	swift test
