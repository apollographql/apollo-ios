// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollo",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Apollo",
            targets: ["Apollo"]),
    ],
    dependencies: [

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
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



// import PackageDescription
//
// let package = Package(
//     name: "Apollo",
//     targets: [
//         Target(name: "Apollo"),
//     ],
//     exclude: ["Tests", "Sources/ApolloSQLite"]
// )
