import Foundation

class ASTField: Codable {
  let responseName: String
  let fieldName: String
  let type: String
  let isConditional: Bool
  let description: String?
  let isDeprecated: Bool?
  let args: [ASTArgument]?
  let fields: [ASTField]?
}
