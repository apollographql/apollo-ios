// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollo",
    products: [
        .library(
            name: "Apollo",
            targets: ["Apollo"]),
		.library(
			name: "ApolloSQLite",
			targets: ["ApolloSQLite"]),
		.library(
			name: "ApolloWebSocket",
			targets: ["ApolloWebSocket"]),
    ],
    dependencies: [
		.package(url: "https://github.com/stephencelis/SQLite.swift.git", .exact("0.12.2")),
		.package(url: "https://github.com/daltoniam/Starscream", .exact("3.1.0")),
    ],
    targets: [
        .target(
            name: "Apollo",
            dependencies: []),
		.target(
			name: "ApolloSQLite",
			dependencies: ["Apollo", "SQLite"]),
		.target(
			name: "ApolloWebSocket",
			dependencies: ["Starscream"]),
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
