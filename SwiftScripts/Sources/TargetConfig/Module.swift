import Foundation
import ApolloCodegenLib

public struct Module {
  public let moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType

  public init?(module: String) {
    switch module.lowercased() {
    case "none": self.moduleType = .none
    case "swiftpackagemanager", "spm": self.moduleType = .swiftPackageManager
    case "other": self.moduleType = .other
    default: return nil
    }
  }

  func outputConfig(
    toTargetRoot targetRootURL: Foundation.URL,
    schemaName: String
  ) -> ApolloCodegenConfiguration.FileOutput {
    let targetPath = targetRootURL.appendingPathComponent(schemaName).path

    return ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(
        path: targetPath,
        schemaName: schemaName,
        moduleType: module
      ),
      operations: .inSchemaModule,
      operationIdentifiersPath: nil
    )
  }
}
