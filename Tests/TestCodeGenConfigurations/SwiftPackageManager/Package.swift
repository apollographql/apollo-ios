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
    .package(name: "AnimalKingdomAPI", path: "./AnimalKingdomAPI")
  ],
  targets: [
    .target(
      name: "TestApp",
      dependencies: [
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "AnimalKingdomAPI", package: "AnimalKingdomAPI")
      ],
      swiftSettings: [
        .unsafeFlags(["-warnings-as-errors"])
      ]
    ),
    .testTarget(
      name: "SwiftPackageTests",
      dependencies: [
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloTestSupport", package: "apollo-ios"),
        .product(name: "AnimalKingdomAPITestMocks", package: "AnimalKingdomAPI")
      ]
    )
  ]
)
