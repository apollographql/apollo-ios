import Foundation
import ApolloCodegenLib

/// Generic representation of a code generation provider.
public protocol CodegenProvider {
  static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL?,
    itemsToGenerate: ApolloCodegen.ItemsToGenerate
  ) throws
}

extension ApolloCodegen: CodegenProvider { }
