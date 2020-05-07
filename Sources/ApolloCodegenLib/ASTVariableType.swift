import Foundation

/// Nestable variable type so that we can determine nullability and lists etc.
/// NOTE: This has to be a class because it contains an instance of itself recursievely
class ASTVariableType: Codable {

  /// What kind of type are we dealing with here?
  enum Kind: String, Codable, CaseIterable {
    case ListType
    case Name
    case NamedType
    case NonNullType
  }
  
  init(kind: Kind,
       name: ASTVariableType?,
       type: ASTVariableType?,
       value: String?) {
    self.kind = kind
    self.name = name
    self.type = type
    self.value = value
  }

  /// The Kind of this type
  let kind: Kind
  
  /// The name of this type
  let name: ASTVariableType?
  
  /// Any further nested type information.
  let type: ASTVariableType?
  
  let value: String?
  
  func isSwiftOptional() -> Bool {
    switch self.kind {
    case .NonNullType:
      return false
    default:
      return true
    }
  }
  
  enum TypeConversionError: Error, LocalizedError {
    case nameNotPresent(forKind: Kind)
    case typeNotPresent(forKind: Kind)
    
    var errorDescription: String? {
      switch self {
      case .typeNotPresent(let kind):
        return "Type \(kind.rawValue) should have a kind"
      case .nameNotPresent(let kind):
        return "Type \(kind.rawValue) should have a name"
      }
    }
  }
  
  func toSwiftType() throws -> String {
    switch self.kind {
      case .ListType:
        guard let innerType = self.type else {
          throw TypeConversionError.typeNotPresent(forKind: self.kind)
        }
        
        let innerSwiftType = try innerType.toSwiftType()
        return "[\(innerSwiftType)]?"
      case .NonNullType:
        guard let innerType = self.type else {
          throw TypeConversionError.typeNotPresent(forKind: self.kind)
        }
      
        let innerSwiftType = try innerType.toSwiftType()
        return try innerSwiftType.apollo.droppingSuffix("?")
      case .NamedType:
        guard let name = self.name else {
          throw TypeConversionError.typeNotPresent(forKind: self.kind)
        }
      
        let innerType = try name.toSwiftType()
        return "\(innerType)?"
      case .Name:
        guard let name = self.value else {
          throw TypeConversionError.nameNotPresent(forKind: self.kind)
        }
             
        return name
    }
  }
  
  func toGraphQLOptional() throws -> String {
    let type = try self.toSwiftType().apollo.droppingSuffix("?")
    return "GraphQLOptional<\(type)>"
  }
}

// Only structs get equatable auto-conformance, so: 
extension ASTVariableType: Equatable {
  static func == (lhs: ASTVariableType, rhs: ASTVariableType) -> Bool {
    lhs.kind == rhs.kind
      && lhs.name == rhs.name
      && lhs.type == rhs.type
      && lhs.value == rhs.value
  }
}
