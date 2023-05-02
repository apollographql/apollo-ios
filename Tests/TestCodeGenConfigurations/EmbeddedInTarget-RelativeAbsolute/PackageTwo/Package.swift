// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PackageTwo",
  platforms: [
    .macOS(.v10_14),
  ],
  products: [
    .library( name: "PackageTwo", targets: ["PackageTwo"]),
    .library(name: "TestMocks", targets: ["TestMocks"]),
  ],
  dependencies: [
    .package(name: "apollo-ios", path: "../../../..")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "PackageTwo",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ]),
    .target(
      name: "TestMocks",
      dependencies: [
        "PackageTwo",
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
      ],
      swiftSettings: [
        .unsafeFlags(["-warnings-as-errors"])
      ]),
    .testTarget(
      name: "PackageTwoTests",
      dependencies: [
        "PackageTwo",
        "TestMocks",
        .product(name: "ApolloAPI", package: "apollo-ios"),
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
      ]),
  ]
)
