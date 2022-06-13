import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces)
/// into Swift code.
struct InterfaceTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
  let graphqlInterface: GraphQLInterfaceType
  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    \(embeddedAccessControlModifier(config: config))\
    final class \(graphqlInterface.name.firstUppercased): Interface { }
    """
    )
  }
}
