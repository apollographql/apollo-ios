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

    case (.swiftEnumCase, .none),
      (.swiftEnumCase, .default):
      return value.asEnumCaseName

    case (.swiftEnumCase, .camelCase):
      return value.convertToCamelCase().asEnumCaseName
    }
  }

}
