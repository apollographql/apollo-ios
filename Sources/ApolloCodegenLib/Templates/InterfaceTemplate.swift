import Foundation

/// Provides the format to convert a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces)
/// into Swift code.
struct InterfaceTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
  let graphqlInterface: GraphQLInterfaceType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile(type: .interface)

  var template: TemplateString {
    """
    \(documentation: graphqlInterface.documentation, config: config)
    static let \(graphqlInterface.formattedName) = Interface(name: "\(graphqlInterface.name)")
    """
  }
}
