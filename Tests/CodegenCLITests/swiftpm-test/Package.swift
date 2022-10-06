// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftpm-test",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "swiftpm-test",
            targets: ["swiftpm-test"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", branch: "fix/xcode-spm-plugin"),
    ],
    targets: [
        .target(
            name: "swiftpm-test",
            dependencies: [
              .product(name: "Apollo", package: "apollo-ios"),
            ]),
    ]
)
