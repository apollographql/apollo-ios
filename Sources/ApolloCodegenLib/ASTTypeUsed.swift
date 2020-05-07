import Foundation

/// A type to generate code for.
struct ASTTypeUsed: Codable, Equatable {
  
  struct Field: Codable, Equatable {
    // The name of the field
    let name: String
    
    /// The type of the field
    let typeNode: ASTVariableType
    
    /// [optional] A description of the field.
    let description: String?
  }

  /// The possible kinds which could be returned through this mechanism
  enum Kind: String, Codable {
    case EnumType
    case InputObjectType
  }

  let kind: ASTTypeUsed.Kind
  
  /// The name of the type
  let name: String

  /// The description of the type
  let description: String

  /// [optional] The values of an enum type
  let values: [ASTEnumValue]?

  /// [optional] Any fields used on this type
  let fields: [ASTTypeUsed.Field]?
}
