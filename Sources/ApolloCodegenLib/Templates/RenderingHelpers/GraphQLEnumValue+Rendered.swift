extension GraphQLEnumValue.Name {

  enum RenderContext {
    /// Renders the value as a case in a generated Swift enum.
    case swiftEnumCase
    /// Renders the value as the rawValue for the enum case.
    case rawValue
  }

  func rendered(
    as context: RenderContext,
    config: ApolloCodegenConfiguration
  ) -> String {
    switch (context, config.options.conversionStrategies.enumCases) {
    case (.rawValue, _):
      return value

    case (.swiftEnumCase, .none):
      return value.asEnumCaseName

    case (.swiftEnumCase, .camelCase):
      return convertToCamelCase(value).asEnumCaseName
    }
  }

  private func convertToCamelCase(_ value: String) -> String {
    if value.allSatisfy({ $0.isUppercase }) {
      // For `UPPERCASE`. e.g) UPPER -> upper, STARWARS -> starwards
      return value.lowercased()
    }
    if value.contains("_") {
      // For `snake_case`. e.g) snake_case -> snakeCase, UPPER_SNAKE_CASE -> upperSnakeCase
      return value.split(separator: "_").enumerated().map { $0.offset == 0 ? $0.element.lowercased() : $0.element.capitalized }.joined()
    }
    if let firstChar = value.first, firstChar.isUppercase {
      // For `UpperCamelCase`. e.g) UpperCamelCase -> upperCamelCase
      return [firstChar.lowercased(), String(value.suffix(from: value.index(value.startIndex, offsetBy: 1)))].joined()
    }
    return value
  }

}
