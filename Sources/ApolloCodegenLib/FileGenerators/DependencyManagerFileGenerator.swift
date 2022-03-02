import Foundation

struct DependencyManagerFileGenerator {
  /// Generates a package manifest file for the releveant depdency manager.
  ///
  /// - Parameters:
  ///   - config: A configuration object specifying output behavior.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ config: ApolloCodegenConfiguration.SchemaTypesFileOutput,
    fileManager: FileManager = FileManager.default
  ) throws {
    switch config.dependencyAutomation {
    case let .swiftPackageManager(moduleName):
      try SwiftPackageManagerFileGenerator.generate(
        moduleName,
        directoryPath: config.path,
        fileManager: fileManager
      )

    default:
      throw NSError(domain: "ApolloCodegen", code: -1, userInfo: [NSLocalizedDescriptionKey: "Only Swift Package Manager is supported at the moment!"])
    }
  }
}

fileprivate struct SwiftPackageManagerFileGenerator {
  /// Generates a Package.swift file for Swift Package Manager support of the generated schema module files.
  ///
  /// - Parameters:
  ///   - moduleName: The name of the library and target of the module.
  ///   - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  ///   - fileManager: `FileManager` object used to create the file.
  static func generate(
    _ moduleName: String,
    directoryPath: String,
    fileManager: FileManager
  ) throws {
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("Package.swift").path

    let data = SwiftPackageManagerModuleTemplate(
      moduleName: moduleName
    ).render().data(using: .utf8)

    try fileManager.apollo.createFile(atPath: filePath, data: data)
  }
}
