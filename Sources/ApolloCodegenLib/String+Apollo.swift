import Foundation
#if !COCOAPODS
import ApolloUtils
#endif

enum ApolloStringError: Error, LocalizedError {
  case expectedSuffixMissing(_ suffix: String)
  
  var errorDescription: String? {
    switch self {
    case .expectedSuffixMissing(let suffix):
      return "Expected \"\(self)\" to have suffix \"\(suffix)\", but it did not. Cannot drop a suffix that doesn't exist!"
    }
  }
}

extension ApolloExtension where Base == String {
  
  func droppingSuffix(_ suffix: String) throws -> String {
    guard base.hasSuffix(suffix) else {
      throw ApolloStringError.expectedSuffixMissing(suffix)
    }
    return String(base.dropLast(suffix.count))
  }
  
  /// Swift identifiers that are keywords
  ///
  /// Some of these are context-dependent and can be used as identifiers outside of the relevant
  /// context. As we don"t understand context, we will treat them as keywords in all contexts.
  ///
  /// This list does not include keywords that aren't identifiers, such as `#available`.
  static var reservedKeywords: Set<String> {
    [
      // https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html#ID413
      // Keywords used in declarations
      "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
      "func", "import", "init", "inout", "internal", "let", "open", "operator",
      "private", "protocol", "public", "static", "struct", "subscript",
      "typealias", "var",
      
      // Keywords used in statements
      "break", "case", "continue", "default", "defer", "do", "else", "fallthrough",
      "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while",
      
      // Keywords used in expressions and types
      "as", "Any", "catch", "false", "is", "nil", "rethrows", "super", "self",
      "Self", "throw", "throws", "true", "try",
      
      // Keywords used in patterns
      "_",
      
      // Keywords reserved in particular contexts
      "associativity", "convenience", "dynamic", "didSet", "final", "get", "infix",
      "indirect", "lazy", "left", "mutating", "none", "nonmutating", "optional",
      "override", "postfix", "precedence", "prefix", "Protocol", "required",
      "right", "set", "Type", "unowned", "weak", "willSet"
    ]
  }
  
  /// Swift identifiers that are keywords in member position
  ///
  /// This is the subset of keywords that are known to still be keywords in member position. The
  /// documentation is not explicit about which keywords qualify, but these are the ones that are
  /// known to have meaning in member position.
  ///
  /// We use this to avoid unnecessary escaping with expressions like `.public`.
  static var reservedMemberKeywords: Set<String> {
    ["self", "Type", "Protocol"]
  }
  
  var sanitizedVariableDeclaration: String {
    guard String.apollo.reservedKeywords.contains(base) else {
      return base
    }
    return "`\(base)`"
  }
  
  var sanitizedVariableUsage: String {
    guard String.apollo.reservedMemberKeywords.contains(base) else {
      return base
    }
    return "`\(base)`"
  }
  
  /// Certain tokens aren't valid as method parameter names, even when escaped with backticks, as
  /// the compiler interprets the keyword and identifier as the same thing. In particular, `self`
  /// works this way.
  /// - parameter input: The proposed parameter name.
  /// - returns: `true` if the name can be used, or `false` if it needs a separate internal parameter name.
  var isValidParameterName: Bool {
    // Right now `self` is the only known token that we can't use with escaping.
    return base != "self"
  }
}
