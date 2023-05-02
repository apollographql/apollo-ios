// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TestApp",
  platforms: [.macOS(.v10_15)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "TestApp",
      targets: ["TestApp"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(name: "apollo-ios", path: "../../.."),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "TestApp",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios")
      ]),
    .testTarget(
      name: "TestAppTests",
      dependencies: [
        "TestApp",
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
      ]),
  ]
)
