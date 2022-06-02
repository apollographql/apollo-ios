import Foundation
import ApolloCodegenLib

/// Generic representation of a code generation provider.
public protocol CodegenProvider {
  static func build(with configuration: ApolloCodegenConfiguration) throws
}

extension ApolloCodegen: CodegenProvider { }
