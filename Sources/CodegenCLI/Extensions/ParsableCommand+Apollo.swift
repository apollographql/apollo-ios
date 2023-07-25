import Foundation
import ArgumentParser
import ApolloCodegenLib

extension ParsableCommand {
  func rootOutputURL(for inputOptions: InputOptions) -> URL? {
    if inputOptions.string != nil { return nil }
    let rootURL = URL(fileURLWithPath: inputOptions.path).deletingLastPathComponent()
    if rootURL.path == FileManager.default.currentDirectoryPath { return nil }
    return rootURL
  }
  
  func checkForCLIVersionMismatch(
    with inputs: InputOptions,
    ignoreVersionMismatch: Bool = false
  ) throws {
    if case let .versionMismatch(cliVersion, apolloVersion) =
        try VersionChecker.matchCLIVersionToApolloVersion(projectRootURL: rootOutputURL(for: inputs)) {
      let errorMessage = """
        Apollo Version Mismatch
        We've detected that the version of the Apollo Codegen CLI does not match the version of the
        Apollo library used in your project. This may lead to incompatible generated objects.

        Please update your version of the Codegen CLI by following the instructions at:
        https://www.apollographql.com/docs/ios/code-generation/codegen-cli/#installation

        CLI version: \(cliVersion)
        Apollo version: \(apolloVersion)
        """

      if ignoreVersionMismatch {
        print("""
          Warning: \(errorMessage)
          """)
      } else {

        throw Error(errorDescription: """
          Error: \(errorMessage)

          To ignore this error during code generation, use the argument: --ignore-version-mismatch.
          """)
      }
    }
  }
}
