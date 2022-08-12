// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "PackageOne",
    platforms: [
        .macOS(.v10_14),
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
                .product(name: "ApolloAPI", package: "apollo-ios"),
                "PackageTwo"
            ]),
        .testTarget(
            name: "PackageOneTests",
            dependencies: ["PackageOne"]),
    ]
)
