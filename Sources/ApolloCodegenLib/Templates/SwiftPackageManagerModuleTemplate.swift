import Foundation

/// Provides the format to define a Swift Package Manager module in Swift code. The output must
/// conform to the [configuration definition of a Swift package](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#).
struct SwiftPackageManagerModuleTemplate: TemplateRenderer {
  /// Module name used to name the generated package.
  let moduleName: String

  var target: TemplateTarget = .moduleFile

  var headerTemplate: TemplateString? { nil }

  var template: TemplateString {
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
    """)
  }
}
