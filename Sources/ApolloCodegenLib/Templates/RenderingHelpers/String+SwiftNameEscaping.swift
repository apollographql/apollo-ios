import Foundation


extension String {
  /// Renders the string as the property name for a field accessor on a generated `SelectionSet`.
  /// This escapes the names of properties that would conflict with Swift reserved keywords.
  var asFieldAccessorPropertyName: String {
    escapeIf(in: SwiftKeywords.FieldAccessorNamesToEscape)
  }

  var asEnumCaseName: String {
    escapeIf(in: SwiftKeywords.FieldAccessorNamesToEscape)
  }

  var asSelectionSetName: String {
    SwiftKeywords.SelectionSetTypeNamesToSuffix.contains(self) ?
    "\(self)_SelectionSet" : self
  }

  var asInputParameterName: String {
    escapeIf(in: SwiftKeywords.InputParameterNamesToEscape)
  }

  var asTestMockFieldPropertyName: String {
    escapeIf(in: SwiftKeywords.TestMockFieldNamesToEscape)
  }

  var asTestMockInitializerParameterName: String? {
    SwiftKeywords.TestMockInitializerParametersToSuffix.contains(self) ?
    "\(self)_value" : nil
  }

  private func escapeIf(in set: Set<String>) -> String {
    set.contains(self) ? "`\(self)`" : self
  }
}

enum SwiftKeywords {

  static let DisallowedFieldNames: Set<String> = [
    "__data", "fragments", "_"
  ]

  static let DisallowedInputParameterNames: Set<String> = [
    "self", "_"
  ]

  static let SelectionSetTypeNamesToSuffix: Set<String> = [
    "Any",
    "DataDict",
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
    "Type"
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
