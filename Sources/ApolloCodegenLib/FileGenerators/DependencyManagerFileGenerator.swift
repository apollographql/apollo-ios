import Foundation

struct DependencyManagerFileGenerator {
  /// Generates a package manifest file for the relevant dependency manager.
  ///
  /// - Parameters:
  ///   - config: A configuration object specifying output behavior.
  ///   - fileManager: `FileManager` object used to create the file. Defaults to `FileManager.default`.
  static func generate(
    _ config: ApolloCodegenConfiguration.SchemaTypesFileOutput,
    fileManager: FileManager = FileManager.default
  ) throws {

    switch config.dependencyAutomation {
    case .manuallyLinked, .carthage, .cocoaPods:
      throw NSError(
        domain: "ApolloCodegen",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "\(config.dependencyAutomation.description) module is not supported at the moment!"]
      )

    default:
      break
    }

    guard
      let filename = config.dependencyAutomation.filename,
      let rendered = config.dependencyAutomation.rendered
    else { return }

    try fileManager.apollo.createFile(
      atPath: URL(fileURLWithPath: config.path).appendingPathComponent(filename).path,
      data: rendered.data(using: .utf8)
    )
  }
}

extension ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .manuallyLinked(_): return "Manually linked"
    case .cocoaPods(_): return "CocoaPods"
    case .carthage(_): return "Carthage"
    case .swiftPackageManager(_): return "Swift Package Manager"
    }
  }
}

fileprivate extension ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType {
  var filename: String? {
    switch self {
    case .swiftPackageManager(_):
      return "Package.swift"

    case .cocoaPods, .carthage, .manuallyLinked:
      return nil
    }
  }

  var rendered: String? {
    switch self {
    case let .swiftPackageManager(moduleName):
      return SwiftPackageManagerModuleTemplate(moduleName: moduleName).render()

    case .cocoaPods, .carthage, .manuallyLinked:
      return nil
    }
  }
}
