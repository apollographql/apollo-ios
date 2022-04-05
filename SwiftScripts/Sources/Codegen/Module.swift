import Foundation
import ApolloCodegenLib

struct Module {
  let moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType

  init?(module: String) {
    switch module.lowercased() {
    case "none": self.moduleType = .none
    case "swiftpackagemanager", "spm": self.moduleType = .swiftPackageManager
    case "other": self.moduleType = .other
    default: return nil
    }
  }

}
