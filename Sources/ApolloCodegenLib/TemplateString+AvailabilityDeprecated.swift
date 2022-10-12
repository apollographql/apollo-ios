extension TemplateString.StringInterpolation {

  mutating func appendInterpolation(
    deprecationReason: String?,
    config: ApolloCodegen.ConfigurationContext
  ) {
    guard
      config.options.warningsOnDeprecatedUsage == .include,
      let deprecationReason = deprecationReason
    else {
      removeLineIfEmpty()
      return
    }

    let deprecationReasonLines = deprecationReason
      .split(separator: "\n", omittingEmptySubsequences: false)

    if deprecationReasonLines.count > 1 {
      appendInterpolation("""
        @available(*, deprecated, message: \"\"\"
          \(deprecationReasonLines.joinedAsLines(withIndent: "  "))
          \"\"\")
        """)
    } else {
      appendInterpolation("""
        @available(*, deprecated, message: \"\(deprecationReason)\")
        """)
    }
  }
}
