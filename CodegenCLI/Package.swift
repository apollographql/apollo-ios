// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CodegenCLI",
  platforms: [
    .macOS(.v10_15)
  ],
  dependencies: [
    .package(name: "Apollo", path: ".."),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.1.2")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "10.0.0")),
  ],
  targets: [
    .executableTarget(
      name: "apollo-ios-codegen",
      dependencies: [
        .product(name: "ApolloCodegenLib", package: "Apollo"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "./Sources"
    ),
    .testTarget(
      name: "CodegenCLITests",
      dependencies: [
        "apollo-ios-codegen",
        "Nimble",
      ],
      path: "./Tests"
    ),
  ]
)
