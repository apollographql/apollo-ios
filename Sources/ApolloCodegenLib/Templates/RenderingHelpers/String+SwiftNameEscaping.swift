import Foundation


extension String {

  var asEnumCaseName: String {
    escapeIf(in: SwiftKeywords.FieldAccessorNamesToEscape)
  }

  var asSelectionSetName: String {
    SwiftKeywords.TypeNamesToSuffix.contains(self) ?
    "\(self)_SelectionSet" : self
  }
  
  var asFragmentName: String {
    let uppercasedName = self.firstUppercased
    return SwiftKeywords.TypeNamesToSuffix.contains(uppercasedName) ?
            "\(uppercasedName)_Fragment" : uppercasedName
  }
  
  var asTestMockFieldPropertyName: String {
    escapeIf(in: SwiftKeywords.TestMockFieldNamesToEscape)
  }

  var asTestMockInitializerParameterName: String? {
    SwiftKeywords.TestMockInitializerParametersToSuffix.contains(self) ?
    "\(self)_value" : nil
  }

  var isConflictingTestMockFieldName: Bool {
    SwiftKeywords.TestMockConflictingFieldNames.contains(self)
  }

  private func escapeIf(in set: Set<String>) -> String {
    set.contains(self) ? "`\(self)`" : self
  }
  
  /// Renders the string as the property name for a field accessor on a generated `SelectionSet`.
  /// This escapes the names of properties that would conflict with Swift reserved keywords.
  func renderAsFieldPropertyName(
    config: ApolloCodegenConfiguration
  ) -> String {
    var propertyName = self
    
    switch config.options.conversionStrategies.fieldAccessor {
    case .camelCase:
      propertyName = propertyName.convertToCamelCase()
    case .idiomatic:
      break
    }
    
    propertyName = propertyName.isAllUppercased ? propertyName.lowercased() : propertyName.firstLowercased
    return propertyName.escapeIf(in: SwiftKeywords.FieldAccessorNamesToEscape)
  }
  
  /// Convert to `camelCase` from a number of different `snake_case` variants.
  ///
  /// All inner `_` characters will be removed, each 'word' will be capitalized, returning a final
  /// firstLowercased string while preserving original leading and trailing `_` characters.
  func convertToCamelCase() -> String {
    guard self.firstIndex(of: "_") != nil else {
      if self.firstIndex(where: { $0.isLowercase }) != nil {
        return self.firstLowercased
      } else {
        return self.lowercased()
      }
    }

    return self.components(separatedBy: "_")
      .map({ $0.isEmpty ? "_" : $0.capitalized })
      .joined()
      .firstLowercased
  }
}

enum SwiftKeywords {

  static let DisallowedFieldNames: Set<String> = [
    "__data", "fragments"
  ]

  static let DisallowedInputParameterNames: Set<String> = [
    "self", "_"
  ]

  static let DisallowedSchemaNamespaceNames: Set<String> = [
    "schema", "apolloapi"
  ]
  
  static let DisallowedEmbeddedTargetNames: Set<String> = [
    "apollo", "apolloapi"
  ]

  static let TypeNamesToSuffix: Set<String> = [
    "Any",
    "DataDict",
    "DocumentType",
    "Fragments",
    "FragmentContainer",
    "ParentType",
    "Protocol",
    "Schema",
    "Selection",
    "Self",
    "String",
    "Bool",
    "Int",
    "Float",
    "Double",
    "ID",
    "Type",
    "Error",
    "_",
  ]

  /// When an interface or union named "Actor" is used as the type for a field on a test mock,
  /// the compiler recognizes it as a "Swift.Actor". The generated `Actor` is only a `typealias`
  /// to `Interface` or `Union`. This error occurs due to Actor's special treatment in the
  /// compiler. To prevent the error, we must namespace the type.
  ///
  /// When the "Actor" type is an object, we do not need to namespace it, as a concrete `Actor`
  /// class is generated in the Test Mocks directory. That class will be recognized by the compiler.
  static let TestMockFieldAbstractTypeNamesToNamespace: Set<String> = [
    "Actor"
  ]

  /// There are some field names that conflict with function names due to the @dynamicMember
  /// subscripting of `Mock`. This set is used to match those field names and generate properties
  /// instead of just relying on the subscript access.
  static let TestMockConflictingFieldNames: Set<String> = [
    "hash"
  ]

  fileprivate static let FieldAccessorNamesToEscape: Set<String> = [
    "associatedtype",
    "class",
    "deinit",
    "enum",
    "extension",
    "fileprivate",
    "func",
    "import",
    "init",
    "inout",
    "internal",
    "let",
    "operator",
    "private",
    "precedencegroup",
    "protocol",
    "Protocol",
    "public",
    "rethrows",
    "static",
    "struct",
    "subscript",
    "typealias",
    "var",
    "break",
    "case",
    "catch",
    "continue",
    "default",
    "defer",
    "do",
    "else",
    "fallthrough",
    "for",
    "guard",
    "if",
    "in",
    "repeat",
    "return",
    "throw",
    "switch",
    "where",
    "while",
    "as",
    "false",
    "is",
    "nil",
    "self",
    "Self",
    "super",
    "throws",
    "true",
    "try",
    "_",
  ]

  fileprivate static let InputParameterNamesToEscape: Set<String> = FieldAccessorNamesToEscape

  fileprivate static let TestMockFieldNamesToEscape: Set<String> =
  FieldAccessorNamesToEscape.union([
    "Type", "Any"
  ])

  fileprivate static let TestMockInitializerParametersToSuffix: Set<String> = [
    "self"
  ]
}
