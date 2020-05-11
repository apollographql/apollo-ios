// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollo",
    products: [
    .library(
      name: "ApolloCore",
      targets: ["ApolloCore"]),
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
      .upToNextMinor(from: "0.12.2")),
    .package(
      url: "https://github.com/daltoniam/Starscream",
      .upToNextMinor(from: "3.1.1")),
    .package(
      url: "https://github.com/stencilproject/Stencil.git",
      .upToNextMinor(from: "0.13.1")),
    ],
    targets: [
      .target(
        name: "ApolloCore",
        dependencies: []),
    .target(
      name: "Apollo",
      dependencies: []),
    .target(
      name: "ApolloCodegenLib",
      dependencies: [
        "ApolloCore",
        .product(name: "Stencil", package: "Stencil"),
      ]),
    .target(
      name: "ApolloSQLite",
      dependencies: [
        "Apollo",
        .product(name: "SQLite", package: "SQLite.swift"),
      ]),
    .target(
      name: "ApolloSQLiteTestSupport",
      dependencies: [
        "ApolloSQLite",
        "ApolloTestSupport"
      ]),
	.target(
      name: "ApolloWebSocket",
      dependencies: [
        "Apollo",
        .product(name: "Starscream", package: "Starscream"),
      ]),
    .target(
      name: "ApolloTestSupport",
      dependencies: [
        "Apollo",
      ]),
    .target(
      name: "GitHubAPI",
      dependencies: [
        "Apollo",
      ]),
    .target(
      name: "StarWarsAPI",
      dependencies: [
        "Apollo",
      ]),

    .testTarget(
      name: "ApolloTests",
      dependencies: [
        "ApolloTestSupport",
        "StarWarsAPI",
      ]),
    .testTarget(
      name: "ApolloCacheDependentTests",
      dependencies: [
        "ApolloSQLiteTestSupport",
        "StarWarsAPI",
      ]),
    .testTarget(
      name: "ApolloCodegenTests",
      dependencies: [
        "ApolloCodegenLib"
      ]),
    .testTarget(
      name: "ApolloSQLiteTests",
      dependencies: [
        "ApolloSQLiteTestSupport",
        "StarWarsAPI"
      ]),
    .testTarget(
      name: "ApolloWebsocketTests",
      dependencies: [
        "ApolloWebSocket",
        "ApolloTestSupport",
        "StarWarsAPI",
      ]),
    ]
)
