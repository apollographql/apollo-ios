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

    if deprecationReason.contains("\n") {
      let indentedDeprecationReason = deprecationReason
        .split(separator: "\n").map { "    \($0)" }.joined(separator: "\n")

      appendInterpolation("""
        @available(*, deprecated, message: \"\"\"
        \(indentedDeprecationReason)
            \"\"\")
        """)
    } else {
      appendInterpolation("""
        @available(*, deprecated, message: \"\(deprecationReason)\")
        """)
    }
  }
}
