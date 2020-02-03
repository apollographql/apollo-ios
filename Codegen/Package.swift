// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    dependencies: [
        .package(path: "../../apollo-ios")
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: ["ApolloCodegenLib"]),
        .testTarget(
            name: "CodegenTests",
            dependencies: ["Codegen"]),
    ]
)
