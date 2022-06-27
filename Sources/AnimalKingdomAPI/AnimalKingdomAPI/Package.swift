// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "AnimalKingdomAPI",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
  ],
  products: [
    .library(name: "AnimalKingdomAPI", targets: ["AnimalKingdomAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-alpha.8"),
  ],
  targets: [
    .target(
      name: "AnimalKingdomAPI",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"
    ),
    .target(
      name: "AnimalKingdomAPITestMocks",
      dependencies: [
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
        .target(name: "AnimalKingdomAPI"),
      ],
      path: "./TestMocks"
    ),
  ]
)