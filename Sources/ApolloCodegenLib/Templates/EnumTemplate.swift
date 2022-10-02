import Foundation

/// Provides the format to convert a [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums) into
/// Swift code.
struct EnumTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Enum](https://spec.graphql.org/draft/#sec-Enums).
  let graphqlEnum: GraphQLEnumType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile(type: .enum)

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
    if config.options.deprecatedEnumCases == .exclude && graphqlEnumValue.isDeprecated {
      return nil
    }

    return """
    \(documentation: graphqlEnumValue.documentation, config: config)
    \(ifLet: graphqlEnumValue.deprecationReason, where: config.options.warningsOnDeprecatedUsage == .include, {"""
      @available(*, deprecated, message: \"\($0)\")
      """})
    \(caseDefinition(for: graphqlEnumValue))
    """
  }

  private func caseDefinition(for graphqlEnumValue: GraphQLEnumValue) -> TemplateString {
    """
    case \(graphqlEnumValue.name.rendered(as: .swiftEnumCase, config: config.config))\
    \(if: config.options.conversionStrategies.enumCases != .none, """
       = "\(graphqlEnumValue.name.rendered(as: .rawValue, config: config.config))"
      """)
    """
  }

}
