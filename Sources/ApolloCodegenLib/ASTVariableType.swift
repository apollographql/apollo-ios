import Foundation

/// Placeholder typealias while this is getting added to tooling
typealias ASTVariableType = String

/// Nestable variable type so that we can determine nullability and lists etc.
class ASTForthcomingVariableType: Codable {

  /// What kind of type are we dealing with here?
  enum Kind: String, Codable, CaseIterable {
    case ENUM
    case INPUT_OBJECT
    case INTERFACE
    case LIST
    case NON_NULL
    case OBJECT
    case SCALAR
    case UNION
  }

  /// The Kind of this type
  let kind: Kind
  
  /// The name of this type
  let name: String?
  
  /// Any further nested type information.
  let ofType: ASTForthcomingVariableType?
  
  enum TypeConversionError: Error, LocalizedError {
    case nameNotPresent(forKind: Kind)
    
    var errorDescription: String? {
      switch self {
      case .nameNotPresent(let kind):
        return "Type \(kind.rawValue) should have a name"
      }
    }
  }
  
  func toSwiftType() throws -> String {
    let inner = try self.ofType?.toSwiftType() ?? ""
    
    switch self.kind {
    case .LIST:
      return "[\(inner)]?"
    case .NON_NULL:
      return try inner.apollo_droppingSuffix("?")
    case .ENUM,
         .INPUT_OBJECT,
         .INTERFACE,
         .OBJECT,
         .SCALAR,
         .UNION:
      guard let name = self.name else {
        throw TypeConversionError.nameNotPresent(forKind: self.kind)
      }
      
      return "\(name)?"
    }
  }
}
