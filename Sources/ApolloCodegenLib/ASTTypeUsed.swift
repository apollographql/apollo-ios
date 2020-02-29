import Foundation

/// A type to generate code for.
class ASTTypeUsed: Codable {
  
  class Field: Codable {
    // The name of the field
    let name: String
    
    /// The type of the field
    let type: ASTVariableType
    
    /// [optional] A description of the field.
    let description: String?
  }
  
  ///  TODO What are the other possible kinds?
  enum Kind: String, Codable {
    case EnumType
    case InputObjectType
  }

  let kind: Kind
  
  /// The name of the type
  let name: String
  
  /// The description of the type
  let description: String
  let values: [ASTEnumValue]?
  
  /// [optional] Any fields used on this type
  let fields: [Field]?
}

class ASTEnumValue: Codable {
  /// The raw name of the enum value
  let name: String
  
  /// The description of the enum value
  let description: String
  
  /// If the enum value is deprecated.
  let isDeprecated: Bool
}
