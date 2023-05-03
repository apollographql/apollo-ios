// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
  name: "PackageOne",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "PackageOne",
      targets: ["PackageOne"]),
  ],
  dependencies: [
    .package(name: "apollo-ios", path: "../../../.."),
    .package(name: "PackageTwo", path: "../PackageTwo")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "PackageOne",
      dependencies: [
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloAPI", package: "apollo-ios"),
        "PackageTwo"
      ],
      exclude: [
        "graphql/AnimalSchema.graphqls",
        "graphql/DogQuery.graphql",
        "graphql/HeightInMeters.graphql",
        "graphql/AllAnimalsLocalCacheMutation.graphql",
        "graphql/PetDetailsMutation.graphql",
        "graphql/ClassroomPets.graphql",
        "graphql/DogFragment.graphql",
        "graphql/ccnGraphql/ClassroomPetsCCN.graphql",
        "graphql/PetSearchQuery.graphql",
        "graphql/AllAnimalsQuery.graphql",
        "graphql/ccnGraphql/AllAnimalsCCN.graphql",
        "graphql/WarmBloodedDetails.graphql",
        "graphql/PetDetails.graphql",
        "graphql/AllAnimalsIncludeSkipQuery.graphql",
        "graphql/PetAdoptionMutation.graphql"
      ],
      swiftSettings: [
        .unsafeFlags(["-warnings-as-errors"])
      ]),
    .testTarget(
      name: "PackageOneTests",
      dependencies: [
        "PackageOne",
        .product(name: "TestMocks", package: "PackageTwo")
      ]),
  ]
)
