extension TemplateString.StringInterpolation {

  mutating func appendInterpolation(
    deprecationReason: String?,
    config: ApolloCodegen.ConfigurationContext
  ) {
    guard
      config.options.warningsOnDeprecatedUsage == .include,
      let escapedDeprecationReason = deprecationReason?.escapedSwiftStringSpecialCharacters()
    else {
      removeLineIfEmpty()
      return
    }

    appendInterpolation("""
      @available(*, deprecated, message: \"\(escapedDeprecationReason)\")
      """)
  }

  mutating func appendInterpolation(
    field: String,
    argument: String,
    warningReason: String
  ) {
    let escapedWarningReason = warningReason.escapedSwiftStringSpecialCharacters()

    appendInterpolation("""
      #warning("Argument '\(argument)' of field '\(field)' is deprecated. \
      Reason: '\(escapedWarningReason)'")
      """)
  }
}

extension String {
  /// Replaces specific escaped characters so they are written into the rendered deprecation
  /// message as escaped characters to be correctly rendered to the user in an Xcode warning
  /// (e.g., `\"` becomes `\\\"`).
  ///
  /// String literals can include the following special characters: `\0` (null character),
  /// `\\` (backslash), `\t` (horizontal tab), `\n` (line feed), `\r` (carriage return),
  /// `\"` (double quotation mark) and `\'` (single quotation mark).
  func escapedSwiftStringSpecialCharacters() -> String {
    var escapedString = String()
    escapedString.reserveCapacity(self.count)

    forEach { character in
      switch (character) {
      case "\0": escapedString.append(#"\0"#)
      case "\\": escapedString.append(#"\\"#)
      case "\t": escapedString.append(#"\t"#)
      case "\n": escapedString.append(#"\n"#)
      case "\r": escapedString.append(#"\r"#)
      case "\"": escapedString.append(#"\""#)
      case "\'": escapedString.append(#"\'"#)
      default: escapedString.append(character)
      }
    }

    return escapedString
  }
}
