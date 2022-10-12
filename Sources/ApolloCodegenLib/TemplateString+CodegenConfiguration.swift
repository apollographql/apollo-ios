extension TemplateString.StringInterpolation {

  mutating func appendInterpolation(
    documentation: String?,
    config: ApolloCodegen.ConfigurationContext
  ) {
    guard config.options.schemaDocumentation == .include else {
      removeLineIfEmpty()
      return
    }

    appendInterpolation(forceDocumentation: documentation)
  }

}
