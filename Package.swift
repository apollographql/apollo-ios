// swift-tools-version:5.6
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
    .library(name: "Apollo", targets: ["Apollo"]),
    .library(name: "ApolloAPI", targets: ["ApolloAPI"]),
    .library(name: "Apollo-Dynamic", type: .dynamic, targets: ["Apollo"]),
    .library(name: "ApolloCodegenLib", targets: ["ApolloCodegenLib"]),
    .library(name: "ApolloSQLite", targets: ["ApolloSQLite"]),
    .library(name: "ApolloWebSocket", targets: ["ApolloWebSocket"]),
    .library(name: "ApolloTestSupport", targets: ["ApolloTestSupport"]),
    .executable(name: "apollo-ios-cli", targets: ["apollo-ios-cli"]),
    .plugin(name: "ApolloCodegenPlugin-Initialize", targets: ["ApolloCodegenPlugin-Initialize"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/stephencelis/SQLite.swift.git",
      .upToNextMinor(from: "0.13.1")),
    .package(
      url: "https://github.com/mattt/InflectorKit",
      .upToNextMinor(from: "1.0.0")),
    .package(
      url: "https://github.com/apple/swift-collections",
      .upToNextMajor(from: "1.0.0")),
    .package(
      url: "https://github.com/apple/swift-argument-parser.git", 
      .upToNextMajor(from: "1.1.2")),
  ],
  targets: [
    .target(
      name: "Apollo",
      dependencies: [
        "ApolloAPI"
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloAPI",
      dependencies: [],
      exclude: [
        "Info.plist"
      ]),    
    .target(
      name: "ApolloCodegenLib",
      dependencies: [
        .product(name: "InflectorKit", package: "InflectorKit"),
        .product(name: "OrderedCollections", package: "swift-collections")
      ],
      exclude: [
        "Info.plist",
        "Frontend/JavaScript",
      ],
      resources: [
        .copy("Frontend/dist/ApolloCodegenFrontend.bundle.js"),
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
        "Apollo"
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloTestSupport",
      dependencies: [
        "ApolloAPI"
      ],
      exclude: [
        "Info.plist"
      ]),
    .executableTarget(
      name: "apollo-ios-cli",
      dependencies: [
        "CodegenCLI",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      exclude: [
        "README.md",
      ]),
    .target(
      name: "CodegenCLI",
      dependencies: [
        "ApolloCodegenLib",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      exclude: [
        "Info.plist",
      ]),
    .plugin(
      name: "ApolloCodegenPlugin-Initialize",
      capability: .command(
        intent: .custom(
          verb: "apollo-codegen-config-init",
          description: "Initialize a new code generation configuration with defaults.")),
      dependencies: [
        "apollo-ios-cli"
      ]),
  ]
)
