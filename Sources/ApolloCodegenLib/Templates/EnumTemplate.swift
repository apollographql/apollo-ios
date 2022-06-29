import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums) into
/// Swift code.
struct EnumTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
  let graphqlEnum: GraphQLEnumType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    \(documentation: graphqlEnum.documentation, config: config)
    \(embeddedAccessControlModifier)\
    enum \(graphqlEnum.name.firstUppercased): String, EnumType {
      \(graphqlEnum.values.compactMap({
        enumCase(for: $0)
      }), separator: "\n")
    }
    
    """
    )
  }

  private func enumCase(for graphqlEnumValue: GraphQLEnumValue) -> TemplateString? {
    switch (
      config.options.deprecatedEnumCases,
      graphqlEnumValue.deprecationReason,
      config.options.warningsOnDeprecatedUsage
    ) {
    case (.exclude, .some, _):
      return nil

    case let (.include, .some(reason), .include):
      return """
        \(documentation: graphqlEnumValue.documentation, config: config)
        @available(*, deprecated, message: \"\(reason)\")
        case \(graphqlEnumValue.name)
        """

    default:
      return """
        \(documentation: graphqlEnumValue.documentation, config: config)
        case \(graphqlEnumValue.name)
        """
    }
  }
}
