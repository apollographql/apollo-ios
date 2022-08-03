// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MySwiftPackage",
  platforms: [
    .macOS(.v10_14),
  ],
  products: [
    .library(
      name: "MySwiftPackage",
      targets: ["MySwiftPackage"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", branch: "1.0/merge-release-test"),
  ],
  targets: [
    .target(
      name: "MySwiftPackage",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ]),
    .testTarget(
      name: "MySwiftPackageTests",
      dependencies: [
        "MySwiftPackage",
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
      ]
    ),
  ]
)
