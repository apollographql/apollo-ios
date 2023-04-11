extension TemplateString.StringInterpolation {

  mutating func appendInterpolation(
    deprecationReason: String?,
    config: ApolloCodegen.ConfigurationContext
  ) {
    guard
      config.options.warningsOnDeprecatedUsage == .include,
      let escapedDeprecationReason = deprecationReason?.escapedDoubleQuotes()
    else {
      removeLineIfEmpty()
      return
    }

    if escapedDeprecationReason.firstIndex(of: "\n") != nil {
      let splitReasonLines = escapedDeprecationReason
        .split(separator: "\n", omittingEmptySubsequences: false)

      appendInterpolation("""
        @available(*, deprecated, message: \"\"\"
          \(splitReasonLines.joinedAsLines(withIndent: "  "))
          \"\"\")
        """)
    } else {
      appendInterpolation("""
        @available(*, deprecated, message: \"\(escapedDeprecationReason)\")
        """)
    }
  }

  mutating func appendInterpolation(
    field: String,
    argument: String,
    warningReason: String
  ) {
    let escapedWarningReason = warningReason.escapedDoubleQuotes()

    appendInterpolation("""
      #warning("Argument '\(argument)' of field '\(field)' is deprecated. \
      Reason: '\(escapedWarningReason)'")
      """)
  }
}

fileprivate extension String {
  func escapedDoubleQuotes() -> String {
    replacingOccurrences(of: "\"", with: "\\\"")
  }
}
