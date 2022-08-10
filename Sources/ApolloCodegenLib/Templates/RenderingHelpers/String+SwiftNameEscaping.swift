import Foundation


extension String {
  /// Renders the string as the property name for a field accessor on a generated `SelectionSet`.
  /// This escapes the names of properties that would conflict with Swift reserved keywords.
  var asFieldAccessorName: String {
    SwiftKeywords.FieldAccessorNamesToEscape.contains(self) ? "`\(self)`" : self
  }
}

fileprivate enum SwiftKeywords {
  static let FieldAccessorNamesToEscape: Set<String> = [
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
    "_",
  ]
}
