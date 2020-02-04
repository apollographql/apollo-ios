// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-tools-support-core", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: ["ApolloCodegenLib", "SwiftToolsSupport-auto"]),
        .testTarget(
            name: "CodegenTests",
            dependencies: ["Codegen"]),
    ]
)
