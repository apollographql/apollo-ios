import Foundation
import ApolloCodegenLib

public struct Module {
  public let moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType

  public init?(module: String) {
    switch module.lowercased() {
    case "none": self.moduleType = .embeddedInTarget(name: "")
    case "swiftpackagemanager", "spm": self.moduleType = .swiftPackageManager
    case "other": self.moduleType = .other
    default: return nil
    }
  }
}
