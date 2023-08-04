import Foundation
import ApolloCodegenLib

/// Generic representation of a code generation provider.
public protocol CodegenProvider {
  static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL?,
    buildOptions: ApolloCodegen.CodeGenerationBuildOptions
  ) throws
}

extension ApolloCodegen: CodegenProvider { }
