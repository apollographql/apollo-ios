import Foundation

/// Provides the format to convert a [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces)
/// into Swift code.
struct InterfaceTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Interface](https://spec.graphql.org/draft/#sec-Interfaces).
  let graphqlInterface: GraphQLInterfaceType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    let name = graphqlInterface.name.firstUppercased
    return """
    \(documentation: graphqlInterface.documentation, config: config)
    \(embeddedAccessControlModifier)\
    let \(name) = Interface(name: "\(name)")
    """
  }
}
