import Foundation
import ApolloCodegenLib

enum Module {
  case swiftPackageManager(name: String)
  case cocoapods(name: String)
  case carthage(name: String)
  case manuallyLinked(name: String)

  init?(module: String, name: String) {
    switch module {
    case "SwiftPackageManager", "SPM": self = .swiftPackageManager(name: name)
    case "CocoaPods": self = .cocoapods(name: name)
    case "Carthage": self = .carthage(name: name)
    case "ManuallyLinked": self = .manuallyLinked(name: name)
    default: return nil
    }
  }

  func outputConfig(toTargetRoot targetRootURL: Foundation.URL) -> ApolloCodegenConfiguration.FileOutput {
    let targetPath = targetRootURL.appendingPathComponent("Generated").path

    let moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType
    switch self {
    case let .swiftPackageManager(name): moduleType = .swiftPackageManager(moduleName: name)
    case let .cocoapods(name): moduleType = .cocoaPods(moduleName: name)
    case let .carthage(name): moduleType = .carthage(moduleName: name)
    case let .manuallyLinked(name): moduleType = .manuallyLinked(namespace: name)
    }

    return ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(
        path: targetPath,
        dependencyAutomation: moduleType
      ),
      operations: .inSchemaModule,
      operationIdentifiersPath: nil
    )
  }
}
