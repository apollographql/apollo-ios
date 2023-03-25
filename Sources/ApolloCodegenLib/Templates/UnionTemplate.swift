import Foundation

/// Provides the format to convert a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions)
/// into Swift code.
struct UnionTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
  let graphqlUnion: GraphQLUnionType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile(type: .union)

  var template: TemplateString {
    TemplateString(
    """
    \(documentation: graphqlUnion.documentation, config: config)
    static let \(graphqlUnion.name.firstUppercased) = Union(
      name: "\(graphqlUnion.name)",
      possibleTypes: \(PossibleTypesTemplate())
    )
    """
    )
  }

  private func PossibleTypesTemplate() -> TemplateString {
    "[\(list: graphqlUnion.types.map(PossibleTypeTemplate))]"
  }

  private func PossibleTypeTemplate(
    _ type: GraphQLObjectType
  ) -> TemplateString {
    """
    \(if: !config.output.schemaTypes.isInModule, "\(config.schemaNamespace.firstUppercased).")\
    Objects.\(type.name.firstUppercased).self
    """
  }

}
