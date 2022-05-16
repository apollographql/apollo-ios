import Foundation

/// Provides the format to define a Swift Package Manager module in Swift code. The output must
/// conform to the [configuration definition of a Swift package](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#).
struct SwiftPackageManagerModuleTemplate: TemplateRenderer {
  /// Module name used to name the generated package.
  let moduleName: String

  let testMockConfig: ApolloCodegenConfiguration.TestMockFileOutput

  let target: TemplateTarget = .moduleFile

  let headerTemplate: TemplateString? = nil

  var template: TemplateString {
    TemplateString("""
    // swift-tools-version:5.3

    import PackageDescription

    let package = Package(
      name: "\(moduleName.firstUppercased)",
      platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v5),
      ],
      products: [
        .library(name: "\(moduleName.firstUppercased)", targets: ["\(moduleName.firstUppercased)"]),
      ],
      dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-alpha.4"),
      ],
      targets: [
        .target(
          name: "\(moduleName.firstUppercased)",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "./Sources"
        ),
        \(ifLet: testMockTarget(), { """
        .target(
          name: "\($0.targetName)",
          dependencies: [
            .product(name: "ApolloTestSupport", package: "apollo-ios"),
          ],
          path: "\($0.path)"
        ),
        """})
      ]
    )
    """)
  }

  private func testMockTarget() -> (targetName: String, path: String)? {
    switch testMockConfig {
    case .none, .absolute:
      return nil
    case let .swiftPackage(targetName):
      if let targetName = targetName {
        return (targetName.firstUppercased, "./\(targetName.firstUppercased)")
      } else {
        return ("\(moduleName.firstUppercased)TestMocks", "./TestMocks")
      }
    }
  }
}
