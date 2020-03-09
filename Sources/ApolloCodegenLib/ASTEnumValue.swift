import Foundation

class ASTEnumValue: Codable {
  /// The raw name of the enum value
  let name: String
  
  /// The description of the enum value
  let description: String
  
  /// If the enum value is deprecated.
  let isDeprecated: Bool
  
  /// Initializer for testing
  init(name: String,
       description: String,
       isDeprecated: Bool) {
    self.name = name
    self.description = description
    self.isDeprecated = isDeprecated
  }
}
