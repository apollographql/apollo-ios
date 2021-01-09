// swift-tools-version:5.3
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
      .upToNextMinor(from: "3.1.1")),
    .package(
      url: "https://github.com/stencilproject/Stencil.git",
      .upToNextMinor(from: "0.14.0")),
    .package(
      url: "https://github.com/apple/swift-crypto.git",
      .upToNextMinor(from: "1.1.2")),
    .package(
      url: "https://github.com/apollographql/InflectorKit",
      .upToNextMinor(from: "0.0.2")),
    ],
    targets: [
    .target(
      name: "ApolloCore",
      dependencies: [
        .product(name: "Crypto",
                 package: "swift-crypto",
                 condition: .when(platforms: [.linux]))
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "Apollo",
      dependencies: [
        "ApolloCore",
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloCodegenLib",
      dependencies: [
        "ApolloCore",
        .product(name: "InflectorKit",
                 package: "InflectorKit",
                 condition: .when(platforms: [.macOS])),
        .product(name: "Stencil",
                 package: "Stencil",
                 condition: .when(platforms: [.macOS])),
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
      name: "ApolloSQLiteTestSupport",
      dependencies: [
        "ApolloSQLite",
        "ApolloTestSupport"
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloWebSocket",
      dependencies: [
        "Apollo",
        "ApolloCore",
        .product(name: "Starscream", package: "Starscream"),
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "ApolloTestSupport",
      dependencies: [
        "Apollo",
      ],
      exclude: [
        "Info.plist"
      ]),
    .target(
      name: "GitHubAPI",
      dependencies: [
        "Apollo",
      ],
      exclude: [
        "Info.plist",
        "graphql"
      ]),
    .target(
      name: "StarWarsAPI",
      dependencies: [
        "Apollo",
      ],
      exclude: [
        "Info.plist",
        "graphql"
      ]),
    .target(
      name: "UploadAPI",
      dependencies: [
        "Apollo",
      ],
      exclude: [
        "Info.plist",
        "graphql"
      ]),
    .testTarget(
      name: "ApolloTests",
      dependencies: [
        "ApolloTestSupport",
        "StarWarsAPI",
        "UploadAPI"
      ],
      exclude: [
        "Info.plist"
      ],
      resources: [
        .copy("Resources")
      ]),
    .testTarget(
      name: "ApolloCacheDependentTests",
      dependencies: [
        "ApolloSQLiteTestSupport",
        "StarWarsAPI",
      ],
      exclude: [
        "Info.plist"
      ]),
    .testTarget(
      name: "ApolloCodegenTests",
      dependencies: [
        "ApolloTestSupport",
        "ApolloCodegenLib"
      ],
      exclude: [
        "Info.plist",
        "scripts directory"
      ]),
    .testTarget(
      name: "ApolloSQLiteTests",
      dependencies: [
        "ApolloSQLiteTestSupport",
        "StarWarsAPI"
      ],
      exclude: [
        "Info.plist"
      ]),
    .testTarget(
      name: "ApolloWebsocketTests",
      dependencies: [
        "ApolloWebSocket",
        "ApolloTestSupport",
        "StarWarsAPI",
      ],
      exclude: [
        "Info.plist"
      ]),
    ]
)
