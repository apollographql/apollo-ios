import Foundation

/// Provides the format to convert a [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects)
/// into Swift code.
struct ObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    """
    \(documentation: graphqlObject.documentation, config: config)
    \(embeddedAccessControlModifier)\
    let \(graphqlObject.name.firstUppercased) = Object(
      typename: "\(graphqlObject.name.firstUppercased)\",
      implementedInterfaces: \(ImplementedInterfacesTemplate())
    )
    """
  }

  private func ImplementedInterfacesTemplate() -> TemplateString {
    return """
    [\(list: graphqlObject.interfaces.map({ interface in
          "\(interface.name.firstUppercased).self"
      }))]
    """
  }
}
