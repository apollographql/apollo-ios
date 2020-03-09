import Foundation

/// A case within an enum
struct ASTEnumValue: Codable, Equatable {
  /// The raw name of the enum value
  let name: String
  
  /// The description of the enum value
  let description: String
  
  /// If the enum value is deprecated.
  let isDeprecated: Bool
}
