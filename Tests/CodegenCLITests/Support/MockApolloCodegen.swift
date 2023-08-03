import Foundation
import CodegenCLI
import ApolloCodegenLib

class MockApolloCodegen: CodegenProvider {
  static var buildHandler: ((ApolloCodegenConfiguration) throws -> Void)? = nil
  static var generateOperationManifestHandler: ((ApolloCodegenConfiguration) throws -> Void)? = nil

  static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL?
  ) throws {
    guard let handler = buildHandler else {
      fatalError("You must set buildHandler before calling \(#function)!")
    }

    defer {
      buildHandler = nil
    }

    try handler(configuration)
  }
  
  static func generateOperationManifest(
    with configuration: ApolloCodegenLib.ApolloCodegenConfiguration,
    withRootURL rootURL: URL?,
    fileManager: ApolloCodegenLib.ApolloFileManager
  ) throws {
    guard let handler = generateOperationManifestHandler else {
      fatalError("You must set generateOperationManifestHandler before calling \(#function)!")
    }
    
    defer {
      generateOperationManifestHandler = nil
    }
    
    try handler(configuration)
  }
}
