import Foundation

class ASTField: Codable {
  let responseName: String
  let fieldName: String
  let type: ASTVariableType
  let isConditional: Bool
  let description: String?
  let isDeprecated: Bool?
  let args: [ASTArgument]?
  let fields: [ASTField]?
  let fragmentSpreads: [String]?
  let inlineFragments: [ASTInlineFragment]?
}
