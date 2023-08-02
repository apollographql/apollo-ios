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
    \(accessControlModifier(for: .parent))\
    enum \(graphqlEnum.formattedName): String, EnumType {
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

    let shouldRenderDocumentation = graphqlEnumValue.documentation != nil &&
    config.options.schemaDocumentation == .include

    return """
    \(if: shouldRenderDocumentation, "\(forceDocumentation: graphqlEnumValue.documentation)")
    \(ifLet: graphqlEnumValue.deprecationReason, { """
      \(if: shouldRenderDocumentation, "///")
      \(forceDocumentation: "**Deprecated**: \($0.escapedSwiftStringSpecialCharacters())")
      """ })
    \(caseDefinition(for: graphqlEnumValue))
    """
  }

  private func caseDefinition(for graphqlEnumValue: GraphQLEnumValue) -> TemplateString {
    """
    case \(graphqlEnumValue.name.rendered(as: .swiftEnumCase, config: config.config))\
    \(if: !config.options.conversionStrategies.enumCases.isDefault, """
       = "\(graphqlEnumValue.name.rendered(as: .rawValue, config: config.config))"
      """)
    """
  }

}
