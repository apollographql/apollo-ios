import Foundation

struct SchemaModuleFileGenerator {
  /// Generates a module for the chosen dependency manager.
  ///
  /// - Parameters:
  ///   - config: A configuration object specifying output behavior.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ config: ApolloCodegen.ConfigurationContext,
    fileManager: ApolloFileManager = .default
  ) throws {

    let pathURL: URL = URL(
      fileURLWithPath: config.output.schemaTypes.path,
      relativeTo: config.rootURL
    )
    let filePath: String
    let rendered: String

    switch config.output.schemaTypes.moduleType {
    case .swiftPackageManager:
      filePath = pathURL.appendingPathComponent("Package.swift").path
      rendered = SwiftPackageManagerModuleTemplate(
        moduleName: config.schemaName,
        testMockConfig: config.output.testMocks,
        config: config
      ).render()

    case .embeddedInTarget:
      filePath = pathURL
        .appendingPathComponent("\(config.schemaName.firstUppercased).graphql.swift").path
      rendered = SchemaModuleNamespaceTemplate(
        namespace: config.schemaName,
        config: config
        ).render()

    case .other:
      // no-op - the implementation is import statements in the generated operation files
      return
    }

    try fileManager.createFile(
      atPath: filePath,
      data: rendered.data(using: .utf8)
    )
  }
}
