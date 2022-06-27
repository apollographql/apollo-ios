// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CodegenCLI",
  platforms: [
    .macOS(.v10_15)
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-alpha.8"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.1.2")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "10.0.0")),
  ],
  targets: [
    .executableTarget(
      name: "apollo-ios-cli",
      dependencies: [
        .product(name: "ApolloCodegenLib", package: "apollo-ios"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "./Sources"
    ),
    .testTarget(
      name: "CodegenCLITests",
      dependencies: [
        "apollo-ios-cli",
        "Nimble",
      ],
      path: "./Tests"
    ),
  ]
)
