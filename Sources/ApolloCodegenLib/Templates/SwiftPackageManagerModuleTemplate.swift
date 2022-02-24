import Foundation

struct SwiftPackageManagerModuleTemplate {
  let moduleName: String

  func render() -> String {
    TemplateString("""
    // swift-tools-version:5.3

    import PackageDescription

    let package = Package(
      name: "\(moduleName)",
      platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v5),
      ],
      products: [
        .library(name: "\(moduleName)", targets: ["\(moduleName)"]),
      ],
      dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-alpha.2"),
      ],
      targets: [
        .target(
          name: "\(moduleName)",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "."
        ),
      ]
    )
    """).description
  }
}
