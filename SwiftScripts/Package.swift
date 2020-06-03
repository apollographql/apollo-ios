// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    platforms: [
        .macOS(.v10_13)
    ],
    dependencies: [
        .package(name: "Apollo", path: ".."),
        .package(url: "https://github.com/apple/swift-tools-support-core", from: "0.0.1"),
        .package(url: "https://github.com/eneko/SourceDocs.git", .upToNextMinor(from: "1.1.0"))
    ],
    targets: [
        .target(name: "Codegen",
                dependencies: [
                    .product(name: "ApolloCodegenLib", package: "Apollo"),
                    .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                ]),
        .target(name: "SchemaDownload",
                dependencies: [
                    .product(name: "ApolloCodegenLib", package: "Apollo"),
                ]),
        .target(name: "DocumentationGenerator",
                dependencies: [
                    .product(name: "ApolloCodegenLib", package: "Apollo"),
                    .product(name: "SourceDocsLib", package: "SourceDocs"),
                ]),
        .testTarget(name: "CodegenTests",
                    dependencies: [
                        "Codegen"
                    ]),
    ]
)
