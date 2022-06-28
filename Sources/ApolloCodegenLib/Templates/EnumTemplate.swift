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
    \(embeddedAccessControlModifier)\
    enum \(graphqlEnum.name.firstUppercased): String, EnumType {
      \(graphqlEnum.values.compactMap({
        evaluateDeprecation(graphqlEnumValue: $0)
      }), separator: "\n")
    }
    """
    )
  }

  private func evaluateDeprecation(graphqlEnumValue: GraphQLEnumValue) -> String? {
    switch (config.options.deprecatedEnumCases, graphqlEnumValue.deprecationReason) {
    case (.exclude, .some): return nil
    default: return "case \(graphqlEnumValue.name)"
    }
  }
}
