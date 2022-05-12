import Foundation
import ApolloUtils

struct SchemaModuleFileGenerator {
  /// Generates a module for the chosen dependency manager.
  ///
  /// - Parameters:
  ///   - config: A configuration object specifying output behavior.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ config: ReferenceWrapped<ApolloCodegenConfiguration>,
    fileManager: FileManager = FileManager.default
  ) throws {

    let pathURL: URL = URL(fileURLWithPath: config.output.schemaTypes.path)
    let filePath: String
    let rendered: String

    switch config.output.schemaTypes.moduleType {
    case .swiftPackageManager:
      filePath = pathURL.appendingPathComponent("Package.swift").path
      rendered = SwiftPackageManagerModuleTemplate(moduleName: config.schemaName).render(forConfig: config)

    case .embeddedInTarget:
      filePath = pathURL.appendingPathComponent("\(config.schemaName).swift").path
      rendered = SchemaModuleNamespaceTemplate(namespace: config.schemaName).render(forConfig: config)

    case .other:
      // no-op - the implementation is import statements in the generated operation files
      return
    }

    try fileManager.apollo.createFile(
      atPath: filePath,
      data: rendered.data(using: .utf8)
    )
  }
}
