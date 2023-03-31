// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "TestApp",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_15),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "TestApp", targets: ["TestApp"]),
  ],
  dependencies: [
    .package(name: "apollo-ios", path: "../../../"),
    .package(name: "GraphQLSchemaName", path: "./Packages/GraphQLSchemaName")
  ],
  targets: [
    .target(
      name: "TestApp",
      dependencies: [
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "GraphQLSchemaName", package: "GraphQLSchemaName")
      ]
    )
  ]
)
