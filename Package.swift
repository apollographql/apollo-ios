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
      name: "ApolloCore",
      dependencies: [],
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
        "InflectorKit",
        .product(name: "Stencil", package: "Stencil"),
      ],
      exclude: [
        "Info.plist",
        "Frontend/JavaScript",
      ],
      resources: [
        .copy("Frontend/JavaScript/dist/ApolloCodegenFrontend.bundle.js")
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
