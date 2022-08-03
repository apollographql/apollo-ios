// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PackageTwo",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PackageTwo",
            targets: ["PackageTwo"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apollographql/apollo-ios.git", branch: "1.0/merge-release-test"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PackageTwo",
            dependencies: [
                .product(name: "ApolloAPI", package: "apollo-ios"),
            ]),
        .testTarget(
            name: "PackageTwoTests",
            dependencies: [
              "PackageTwo",
              .product(name: "ApolloTestSupport", package: "apollo-ios"),
            ]),
    ]
)
