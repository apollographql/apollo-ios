import Foundation

/// An argument which can be 
class ASTArgument: Codable {
  let name: String
  let value: JSONContainer
  let type: ASTVariableType
}
