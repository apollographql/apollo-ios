import Foundation
import ApolloCodegenLib

/// Generic representation of a code generation provider.
public protocol CodegenProvider {
  static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL?
  ) throws
  
  static func generateOperationManifest(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL?,
    fileManager: ApolloFileManager
  ) throws
}

extension ApolloCodegen: CodegenProvider { }
