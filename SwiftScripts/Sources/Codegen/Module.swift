import Foundation
import ApolloCodegenLib

struct Module {
  private let module: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType

  init?(module: String) {
    switch module.lowercased() {
    case "none": self.module = .none
    case "swiftpackagemanager", "spm": self.module = .swiftPackageManager
    case "other": self.module = .other
    default: return nil
    }
  }

  func outputConfig(
    toTargetRoot targetRootURL: Foundation.URL,
    schemaName: String
  ) -> ApolloCodegenConfiguration.FileOutput {
    let targetPath = targetRootURL.appendingPathComponent("Generated").path

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
