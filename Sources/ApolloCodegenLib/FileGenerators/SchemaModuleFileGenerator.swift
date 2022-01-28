import Foundation

/// Generates a package manifest file for the releveant depdency manager.
struct SchemaModuleFileGenerator: FileGenerator, Equatable {
  var path: String { fileGenerator.path }
  var data: Data? { fileGenerator.data }

  private let fileGenerator: FileGenerator

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - configuration: A configuration object that specifies properties such as which dependency manager and where the file
  ///  should be output to.
  init(_ configuration: ApolloCodegenConfiguration.SchemaTypesFileOutput) {
    switch configuration.dependencyAutomation {
    case let .swiftPackageManager(moduleName):
      self.fileGenerator = SwiftPackageManagerFileGenerator(
        moduleName: moduleName,
        directoryPath: configuration.modulePath
      )

    default:
      fatalError("Only Swift Package Manager is supported at the moment!")
    }
  }

  func generateFile(fileManager: FileManager = FileManager.default) throws {
    try fileGenerator.generateFile(fileManager: fileManager)
  }

  static func == (lhs: SchemaModuleFileGenerator, rhs: SchemaModuleFileGenerator) -> Bool {
    return lhs.path == rhs.path
  }
}

/// Generates a Package.swift file for Swift Package Manager support of the generated schema module files.
fileprivate struct SwiftPackageManagerFileGenerator: FileGenerator, Equatable {
  let path: String
  /// The name of the library and target of the module.
  let moduleName: String

  var data: Data? {
    SwiftPackageManagerModuleTemplate(moduleName: moduleName)
      .render()
      .data(using: .utf8)
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///   - moduleName: The name of the library and target of the module.
  ///   - directoryPath: The directory path where the package manifest will be output.
  init(moduleName: String, directoryPath: String) {
    self.moduleName = moduleName
    self.path = URL(fileURLWithPath: directoryPath).appendingPathComponent("Package.swift").path
  }
}
