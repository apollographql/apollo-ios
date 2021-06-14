// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Apollo",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5)
  ],
  products: [
    .library(
      name: "Apollo",
      targets: ["Apollo"]),
    .library(
      name: "ApolloAPI",
      targets: ["ApolloAPI"]),
    .library(
      name: "ApolloUtils",
      targets: ["ApolloUtils"]),
    .library(
      name: "Apollo-Dynamic",
      type: .dynamic,
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
      .upToNextMinor(from: "4.0.4")),
    .package(
      url: "https://github.com/stencilproject/Stencil.git",
      .upToNextMinor(from: "0.14.0")),
    .package(
      url: "https://github.com/apollographql/InflectorKit",
      .upToNextMinor(from: "0.0.2")),
  ],
  targets: [
    .target(
      name: "Apollo",
      dependencies: [
        "ApolloAPI",
        "ApolloUtils"
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloAPI",
      dependencies: [],
      exclude: [
        "Info.plist",
        "CodegenV1"
      ]),
    .target(
      name: "ApolloUtils",
      dependencies: [],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloCodegenLib",
      dependencies: [
        "ApolloUtils",
        .product(name: "InflectorKit", package: "InflectorKit"),
        .product(name: "Stencil", package: "Stencil"),
      ],
      exclude: [
        "Info.plist",
        "Frontend/JavaScript",
      ],
      resources: [
        .copy("Frontend/dist/ApolloCodegenFrontend.bundle.js"),
        .copy("Frontend/dist/ApolloCodegenFrontend.bundle.js.map")
      ]),
    .target(
      name: "ApolloSQLite",
      dependencies: [
        "Apollo",
        .product(name: "SQLite", package: "SQLite.swift"),
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloWebSocket",
      dependencies: [
        "Apollo",
        "ApolloUtils",
        .product(name: "Starscream", package: "Starscream"),
      ],
      exclude: [
        "Info.plist"
      ])
  ]
)
