import Foundation

/// Provides the format to convert a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces)
/// into Swift code.
struct InterfaceTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
  let graphqlInterface: GraphQLInterfaceType

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    public final class \(graphqlInterface.name.firstUppercased): Interface { }
    """
    )
  }
}
