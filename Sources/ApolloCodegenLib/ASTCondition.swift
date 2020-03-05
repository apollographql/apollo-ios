import Foundation

/// The details of a specific condition
class ASTCondition: Codable {
  enum Kind: String, Codable {
    case BooleanCondition
    /// TODO: What other kinds are there?
  }
  
  /// The kind of condition
  let kind: ASTCondition.Kind
  
  /// The name of the variable determining this condition
  let variableName: String
  
  /// If the condition is inverted
  let inverted: Bool
  
  /// Initializer for testing
  init(kind: ASTCondition.Kind,
       variableName: String,
       inverted: Bool) {
    self.kind = kind
    self.variableName = variableName
    self.inverted = inverted
  }
}

extension ASTCondition: Equatable {
  // I have no idea why auto-conformance isn't working here
  
  static func == (lhs: ASTCondition, rhs: ASTCondition) -> Bool {
    lhs.kind == rhs.kind
      && lhs.variableName == rhs.variableName
      && lhs.inverted == rhs.inverted
  }
}
