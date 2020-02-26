import Foundation

class ASTFragment: Codable {
  let typeCondition: String
  let possibleTypes: [String]
  let fragmentName: String
  let filePath: String
  let source: String
  let fields: [ASTFragmentField]
  let fragmentSpreads: [String]
  let inlineFragments: [ASTInlineFragment]
}

class ASTInlineFragment: Codable {
  let typeCondition: String
  let possibleTypes: [String]
  let fields: [ASTFragmentField]
  let fragmentSpreads: [String]
}

class ASTFragmentField: Codable {
  let responseName: String
  let fieldName: String
  let type: String
  let isConditional: Bool
  let description: String?
  let isDeprecated: Bool?
  let args: JSONContainer
}

