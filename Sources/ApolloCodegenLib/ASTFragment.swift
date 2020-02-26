import Foundation

class ASTFragment: Codable {
  let typeCondition: String
  let possibleTypes: [String]
  let fragmentName: String
  let filePath: String
  let source: String
  let fields: [ASTField]
  let fragmentSpreads: [String]
  let inlineFragments: [ASTInlineFragment]
}

class ASTInlineFragment: Codable {
  let typeCondition: String
  let possibleTypes: [String]
  let fields: [ASTField]
  let fragmentSpreads: [String]
}
