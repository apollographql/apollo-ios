import Foundation

class ASTFragment: Codable {
  let typeCondition: ASTVariableType
  let possibleTypes: [String]
  let fragmentName: String
  let filePath: String
  let source: String
  let fields: [ASTField]
  
  /// Names of fragments referenced at this level.
  let fragmentSpreads: [String]
  
  /// Fragments defined inline on a particuar object type such as `... on Droid`
  let inlineFragments: [ASTInlineFragment]
}

class ASTInlineFragment: Codable {
  let typeCondition: ASTVariableType
  let possibleTypes: [String]
  let fields: [ASTField]
  let fragmentSpreads: [String]
}
