// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "Apollo",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "Apollo", targets: ["Apollo"]),
    .library(name: "ApolloAPI", targets: ["ApolloAPI"]),
    .library(name: "Apollo-Dynamic", type: .dynamic, targets: ["Apollo"]),
    .library(name: "ApolloSQLite", targets: ["ApolloSQLite"]),
    .library(name: "ApolloWebSocket", targets: ["ApolloWebSocket"]),
    .library(name: "ApolloTestSupport", targets: ["ApolloTestSupport"]),
    .plugin(name: "InstallCLI", targets: ["Install CLI"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-atomics",
      .upToNextMajor(from: "1.2.0"))
  ],
  targets: [
    .target(
      name: "Apollo",
      dependencies: [
        "ApolloAPI",
        .product(name: "Atomics", package: "swift-atomics"),
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .target(
      name: "ApolloAPI",
      dependencies: [],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .target(
      name: "ApolloSQLite",
      dependencies: [
        "Apollo",
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloWebSocket",
      dependencies: [
        "Apollo"
      ],
      resources: [
        .copy("Resources/PrivacyInfo.xcprivacy")
      ],
      swiftSettings: [.enableUpcomingFeature("ExistentialAny")]
    ),
    .target(
      name: "ApolloTestSupport",
      dependencies: [
        "Apollo",
        "ApolloAPI"
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
  ],
  swiftLanguageVersions: [.version("6"), .v5]
)
