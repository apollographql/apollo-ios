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

  /// Convert to `camelCase` from a number of different `snake_case` variants.
  ///
  /// All inner `_` characters will be removed, each 'word' will be capitalized, returning a final
  /// firstLowercased string while preserving original leading and trailing `_` characters.
  private func convertToCamelCase(_ value: String) -> String {
    guard value.firstIndex(of: "_") != nil else {
      if value.firstIndex(where: { $0.isLowercase }) != nil {
        return value.firstLowercased
      } else {
        return value.lowercased()
      }
    }

    return value.components(separatedBy: "_")
      .map({ $0.isEmpty ? "_" : $0.capitalized })
      .joined()
      .firstLowercased
  }

}
