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
    switch (
      config.options.deprecatedEnumCases,
      graphqlEnumValue.deprecationReason,
      config.options.warningsOnDeprecatedUsage,
      config.options.enumCaseConvertStrategy
    ) {
    case (.exclude, .some, _, _):
      return nil

    case let (.include, .some(reason), .include, .none):
      return """
        \(documentation: graphqlEnumValue.documentation, config: config)
        @available(*, deprecated, message: \"\(reason)\")
        case \(graphqlEnumValue.name.asEnumCaseName)
        """
    case let (.include, .some(reason), .include, .camelCase):
      return """
        \(documentation: graphqlEnumValue.documentation, config: config)
        @available(*, deprecated, message: \"\(reason)\")
        case \(convertToCamelCase(graphqlEnumValue.name)) = "\(graphqlEnumValue.name)"
        """
    case (_, _, _, .camelCase):
      return """
        \(documentation: graphqlEnumValue.documentation, config: config)
        case \(convertToCamelCase(graphqlEnumValue.name)) = "\(graphqlEnumValue.name)"
        """
    default:
      return """
        \(documentation: graphqlEnumValue.documentation, config: config)
        case \(graphqlEnumValue.name.asEnumCaseName)
        """
    }
  }

  private func convertToCamelCase(_ value: String) -> String {
    if value.allSatisfy({ $0.isUppercase }) {
      // e.g) UPPER -> upper, STARWARS -> starwards
      return value.lowercased()
    }
    if value.contains("_") {
      // e.g) snake_case -> snakeCase, UPPER_SNAKE_CASE -> upperSnakeCase
      return value.split(separator: "_").enumerated().map { $0.offset == 0 ? $0.element.lowercased() : $0.element.capitalized }.joined()
    }
    if let firstChar = value.first, firstChar.isUppercase {
      // e.g) UpperCamelCase -> upperCamelCase
      return [firstChar.lowercased(), String(value.suffix(from: value.index(value.startIndex, offsetBy: 1)))].joined()
    }
    return value
  }
}
