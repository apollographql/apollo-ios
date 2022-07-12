// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Codegen",
  platforms: [
    .macOS(.v10_15)
  ],
  dependencies: [
    .package(name: "Apollo", path: ".."),
    .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.0.2"))
  ],
  targets: [
    .target(name: "TargetConfig",
            dependencies: [
              .product(name: "ApolloCodegenLib", package: "Apollo"),
            ]),
    .target(name: "Codegen",
            dependencies: [
              .product(name: "ApolloCodegenLib", package: "Apollo"),
              .product(name: "ArgumentParser", package: "swift-argument-parser"),
              .target(name: "TargetConfig"),
            ]),
    .target(name: "SchemaDownload",
            dependencies: [
              .product(name: "ApolloCodegenLib", package: "Apollo"),
              .target(name: "TargetConfig"),
            ]),
    .target(name: "DocumentationGenerator",
            dependencies: [
              .product(name: "ApolloCodegenLib", package: "Apollo")              
            ]),
    .testTarget(name: "CodegenTests",
                dependencies: [
                  "Codegen"
                ]),
  ]
)
