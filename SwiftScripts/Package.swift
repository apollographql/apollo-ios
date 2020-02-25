// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-tools-support-core", from: "0.0.1"),
        .package(url: "https://github.com/designatednerd/SourceDocs.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: ["ApolloCodegenLib", "SwiftToolsSupport-auto"]),
        .target(name: "SchemaDownload",
                dependencies: ["ApolloCodegenLib"]),
        .target(name: "DocumentationGenerator",
                dependencies: ["ApolloCodegenLib", "SourceDocsLib"]),
        .testTarget(
            name: "CodegenTests",
            dependencies: ["Codegen"]),
    ]
)
