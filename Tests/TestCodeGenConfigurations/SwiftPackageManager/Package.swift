// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "GraphQLSchemaName",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "GraphQLSchemaName", targets: ["GraphQLSchemaName"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-beta.4"),
  ],
  targets: [
    .target(
      name: "GraphQLSchemaName",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
    .target(
      name: "GraphQLSchemaNameTestMocks",
      dependencies: [
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
        .target(name: "GraphQLSchemaName"),
      ],
      path: "./TestMocks"
    ),
  ]
)
