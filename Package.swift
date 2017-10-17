// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollo",
    products: [
        .library(
            name: "Apollo",
            targets: ["Apollo"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "Apollo",
            dependencies: []),
        .testTarget(
            name: "ApolloTestSupport",
            dependencies: ["Apollo"]),
        .testTarget(
            name: "StarWarsAPI",
            dependencies: ["Apollo"]),
        .testTarget(
            name: "ApolloTests",
            dependencies: ["ApolloTestSupport", "StarWarsAPI"]),
        .testTarget(
            name: "ApolloPerformanceTests",
            dependencies: ["ApolloTestSupport", "StarWarsAPI"]),
    ]
)
