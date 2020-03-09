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
    
    /// Initializer for testing
    init(name: String,
         type: ASTVariableType,
         description: String?) {
      self.name = name
      self.type = type
      self.description = description
    }
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
  
  /// Initializer for testing
  init(kind: ASTTypeUsed.Kind,
       name: String,
       description: String,
       values: [ASTEnumValue]?,
       fields: [ASTTypeUsed.Field]?) {
    self.kind = kind
    self.name = name
    self.description = description
    self.values = values
    self.fields = fields
  }
}
