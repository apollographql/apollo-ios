import Foundation

/// Represents a union type
struct ASTUnionType: Codable, Equatable {
  
  /// The name of the union type
  let name: String
  
  /// The names of the types represented by the union type
  let types: [String]
  
  /// Initializer for testing
  init(name: String,
       types: [String]) {
    self.name = name
    self.types = types
  }
}
