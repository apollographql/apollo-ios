import Foundation

struct SchemaModuleFileGenerator {
  /// Generates a module for the chosen dependency manager.
  ///
  /// - Parameters:
  ///   - config: A configuration object specifying output behavior.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ config: ApolloCodegenConfiguration.SchemaTypesFileOutput,
    fileManager: FileManager = FileManager.default
  ) throws {

    let path: String
    let rendered: String

    switch config.moduleType {
    case .swiftPackageManager:
      path = URL(fileURLWithPath: config.path).appendingPathComponent("Package.swift").path
      rendered = SwiftPackageManagerModuleTemplate(moduleName: config.schemaName).render()

    case .none:
      path = URL(fileURLWithPath: config.path).appendingPathComponent("\(config.schemaName).swift").path
      rendered = SchemaModuleNamespaceTemplate(moduleName: config.schemaName).render()

    case .other:
      // no-op - the implementation is import statements in the generated operation files
      return
    }

    try fileManager.apollo.createFile(atPath: path, data: rendered.data(using: .utf8))
  }
}
