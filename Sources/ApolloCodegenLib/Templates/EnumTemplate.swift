import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums) into
/// Swift code.
struct EnumTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
  let graphqlEnum: GraphQLEnumType

  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    \(embeddedAccessControlModifier)\
    enum \(graphqlEnum.name.firstUppercased): String, EnumType {
      \(graphqlEnum.values.compactMap({
        enumCase(for: $0)
      }), separator: "\n")
    }
    """
    )
  }

  private func enumCase(for graphqlEnumValue: GraphQLEnumValue) -> String? {
    switch (
      config.options.deprecatedEnumCases,
      graphqlEnumValue.deprecationReason,
      config.options.warningsOnDeprecatedUsage
    ) {
    case (.exclude, .some, _):
      return nil

    case let (.include, .some(reason), .include):
      return TemplateString("""
        @available(*, deprecated, message: \"\(reason)\")
        case \(graphqlEnumValue.name)
        """).description

    default:
      return "case \(graphqlEnumValue.name)"
    }
  }
}
