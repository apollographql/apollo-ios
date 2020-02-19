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
    .package(
      url: "https://github.com/stephencelis/SQLite.swift.git",
      .exact("0.12.2")),
    .package(
      url: "https://github.com/daltoniam/Starscream",
      .exact("3.1.1")),
    ],
    targets: [
    .target(
      name: "Apollo",
      dependencies: []),
    .target(
      name: "ApolloCodegenLib",
      dependencies: []),
    .target(
      name: "ApolloSQLite",
      dependencies: ["Apollo", "SQLite"]),
    .target(
      name: "ApolloSQLiteTestSupport",
      dependencies: ["ApolloSQLite", "ApolloTestSupport"]),
	.target(
      name: "ApolloWebSocket",
      dependencies: ["Apollo","Starscream"]),
    .target(
      name: "ApolloTestSupport",
      dependencies: ["Apollo"]),
    .target(
      name: "StarWarsAPI",
      dependencies: ["Apollo"]),
    
    .testTarget(
      name: "ApolloTests",
      dependencies: ["ApolloTestSupport", "StarWarsAPI"]),
    .testTarget(
      name: "ApolloSQLiteTests",
      dependencies: ["ApolloSQLite", "ApolloSQLiteTestSupport", "StarWarsAPI"])
    ]
)
