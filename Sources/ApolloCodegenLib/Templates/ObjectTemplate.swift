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
    final class \(graphqlObject.name.firstUppercased): Object {
      override public class var __typename: StaticString { \"\(graphqlObject.name.firstUppercased)\" }

      \(section: ImplementedInterfacesTemplate())
    }

    """
  }

  private func ImplementedInterfacesTemplate() -> TemplateString {
    guard !graphqlObject.interfaces.isEmpty else {
      return ""
    }

    return """
    override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
    private static let _implementedInterfaces: [Interface.Type]? = [
      \(graphqlObject.interfaces.map({ interface in
          "\(interface.name.firstUppercased).self"
      }), separator: ",\n")
    ]
    """
  }
}
