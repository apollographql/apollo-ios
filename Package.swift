// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollo",
    products: [
        .library(
            name: "Apollo",
            targets: ["Apollo"]),
    .library(
      name: "ApolloCodegenLib",
      targets: ["ApolloCodegenLib"]),
		.library(
			name: "ApolloSQLite",
			targets: ["ApolloSQLite"]),
		.library(
			name: "ApolloWebSocket",
			targets: ["ApolloWebSocket"]),
    ],
    dependencies: [
		.package(url: "https://github.com/stephencelis/SQLite.swift.git", .exact("0.12.2")),
		.package(url: "https://github.com/daltoniam/Starscream", .exact("3.1.1")),
    ],
    targets: [
        .target(
            name: "Apollo",
            dependencies: []),
		.target(
			name: "ApolloSQLite",
			dependencies: ["Apollo", "SQLite"]),
    .target(
      name: "ApolloCodegenLib",
      dependencies: []),
		.target(
			name: "ApolloWebSocket",
			dependencies: ["Apollo", "Starscream"]),
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
