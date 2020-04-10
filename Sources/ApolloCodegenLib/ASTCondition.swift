import Foundation

/// The details of a specific condition
struct ASTCondition: Codable, Equatable {
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
}
