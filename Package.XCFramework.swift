// swift-tools-version:5.9
//
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Swift 5.9 is available from Xcode 15.0.
//
// This is an alternative Package.swift that uses precompiled XCFrameworks from the artifacts folder.
// To use this instead of the source-based Package.swift:
// 1. Build the XCFrameworks using: make xcframeworks
// 2. Rename this file to Package.swift (and backup the original)
// 3. Update your package dependencies

import PackageDescription

let package = Package(
  name: "Apollo",
  platforms: [
    .iOS(.v17),
    .watchOS(.v11),
  ],
  products: [
    .library(name: "Apollo", targets: ["Apollo"]),
    .library(name: "ApolloAPI", targets: ["ApolloAPI"]),
    .library(name: "ApolloSQLite", targets: ["ApolloSQLite"]),
  ],
  dependencies: [
  ],
  targets: [
    .binaryTarget(
      name: "Apollo",
      path: "artifacts/Apollo.xcframework"
    ),
    .binaryTarget(
      name: "ApolloAPI",
      path: "artifacts/ApolloAPI.xcframework"
    ),
    .binaryTarget(
      name: "ApolloSQLite",
      path: "artifacts/ApolloSQLite.xcframework"
    ),
  ]
)
