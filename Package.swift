// swift-tools-version:5.9
//
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift 5.9 is available from Xcode 15.0.


import PackageDescription

let package = Package(
  name: "ApolloMigration",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_14),
    .tvOS(.v12),
    .watchOS(.v5),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "ApolloMigration", targets: ["ApolloMigration"]),
    .library(name: "ApolloMigrationAPI", targets: ["ApolloMigrationAPI"]),
    .library(name: "ApolloMigration-Dynamic", type: .dynamic, targets: ["ApolloMigration"]),
    .library(name: "ApolloMigrationSQLite", targets: ["ApolloMigrationSQLite"]),
    .library(name: "ApolloMigrationWebSocket", targets: ["ApolloMigrationWebSocket"]),
    .library(name: "ApolloMigrationTestSupport", targets: ["ApolloMigrationTestSupport"]),
    .plugin(name: "InstallCLI", targets: ["Install CLI"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/stephencelis/SQLite.swift.git",
      .upToNextMajor(from: "0.13.1")),
  ],
  targets: [
    .target(
      name: "ApolloMigration",
      dependencies: [
        "ApolloMigrationAPI"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloMigrationAPI",
      dependencies: [],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloMigrationSQLite",
      dependencies: [
        "ApolloMigration",
        .product(name: "SQLite", package: "SQLite.swift"),
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloMigrationWebSocket",
      dependencies: [
        "ApolloMigration"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloMigrationTestSupport",
      dependencies: [
        "ApolloMigration",
        "ApolloMigrationAPI"
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .plugin(
      name: "Install CLI",
      capability: .command(
        intent: .custom(
          verb: "apollo-cli-install",
          description: "Installs the Apollo iOS Command line interface."),
        permissions: [
          .writeToPackageDirectory(reason: "Downloads and unzips the CLI executable into your project directory."),
          .allowNetworkConnections(scope: .all(ports: []), reason: "Downloads the Apollo iOS CLI executable from the GitHub Release.")
        ]),
      dependencies: [],
      path: "Plugins/InstallCLI"
    )
  ]
)
