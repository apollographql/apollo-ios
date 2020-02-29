import Foundation

/// Placeholder typealias while this is getting added to tooling
typealias ASTVariableType = String

/// Nestable variable type so that we can determine nullability and lists etc.
class ASTForthcomingVariableType: Codable {

  /// What kind of type are we dealing with here?
  enum Kind: String, Codable, CaseIterable {
    case ENUM
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
  let name: String
  
  /// Any further nested type information.
  let ofType: ASTForthcomingVariableType?
}
