import Foundation
import ApolloCodegenLib

enum VersionChecker {
  

  enum Versions {
    static let codegenLibVersion: String? = {
      let codegenBundle = Bundle(for: ApolloCodegen.self)
      let dict = codegenBundle.infoDictionary
      return dict?["CFBundleVersion"] as? String
    }()
  }

  static func verifyCLIVersionMatchesApolloVersion() throws {
    let version = Constants.CLIVersion
    print("CLI Version: \(version)")
    print("Codegen Lib Version: \(Versions.codegenLibVersion)")
  }

}
