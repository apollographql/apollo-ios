import Foundation

/// Provides the format to define a Swift Package Manager module in Swift code. The output must
/// conform to the [configuration definition of a Swift package](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html#).
struct SwiftPackageManagerModuleTemplate: TemplateRenderer {

  let testMockConfig: ApolloCodegenConfiguration.TestMockFileOutput

  let target: TemplateTarget = .moduleFile

  let headerTemplate: TemplateString? = nil

  let config: ApolloCodegen.ConfigurationContext

  var template: TemplateString {
    let casedSchemaName = config.schemaName.firstUppercased

    return TemplateString("""
    // swift-tools-version:5.7

    import PackageDescription

    let package = Package(
      name: "\(casedSchemaName)",
      platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v5),
      ],
      products: [
        .library(name: "\(casedSchemaName)", targets: ["\(casedSchemaName)"]),
        \(ifLet: testMockTarget(), { """
        .library(name: "\($0.targetName)", targets: ["\($0.targetName)"]),
        """})
      ],
      dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
      ],
      targets: [
        .target(
          name: "\(casedSchemaName)",
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
            .target(name: "\(casedSchemaName)"),
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
        return ("\(config.schemaName.firstUppercased)TestMocks", "./TestMocks")
      }
    }
  }
}
