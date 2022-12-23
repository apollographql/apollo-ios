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

  /// Convert to `camelCase` from `snake_case`, `UpperCamelCase`, or `UPPERCASE`.
  ///
  /// 1. Returns a first lowercased string
  /// 1. Capitalizes the word starting after each `_`
  /// 2. Removes all inner `_`
  /// 3. Preserves leading and trailing `_`
  /// 4. Converts an all uppercase string into all lowercase
  private func convertToCamelCase(_ value: String) -> String {
    // The source for this function is from the JSONDecoder implementation in Swift Foundation,
    // licensed under Apache License v2.0 with Runtime Library Exception. Modifications were made
    // to the return when no underscore characters are found.
    //
    // See https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/JSONDecoder.swift

    // Find the first non-underscore character
    guard let firstNonUnderscore = value.firstIndex(where: { $0 != "_" }) else {
      return value
    }

    // Find the last non-underscore character
    var lastNonUnderscore = value.index(before: value.endIndex)
    while lastNonUnderscore > firstNonUnderscore && value[lastNonUnderscore] == "_" {
      value.formIndex(before: &lastNonUnderscore)
    }

    // Cater for leading and trailing underscore characters
    let valueRange = firstNonUnderscore...lastNonUnderscore
    let leadingUnderscoreRange = value.startIndex..<firstNonUnderscore
    let trailingUnderscoreRange = value.index(after: lastNonUnderscore)..<value.endIndex

    // Split inner string into 'words'
    let components = value[valueRange].split(separator: "_")
    let joinedString: String
    if components.count == 1 {
      // No underscore character found
      if value.allSatisfy({ $0.isUppercase }) {
        joinedString = String(value[valueRange]).lowercased()
      } else {
        joinedString = String(value[valueRange]).firstLowercased
      }
    } else {
      joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
    }

    // Do a cheap isEmpty check before creating and appending potentially empty strings
    let result: String
    if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
      result = joinedString
    } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
      // Both leading and trailing underscores
      result = String(value[leadingUnderscoreRange]) + joinedString + String(value[trailingUnderscoreRange])
    } else if (!leadingUnderscoreRange.isEmpty) {
      // Just leading
      result = String(value[leadingUnderscoreRange]) + joinedString
    } else {
      // Just trailing
      result = joinedString + String(value[trailingUnderscoreRange])
    }
    return result
  }

}
