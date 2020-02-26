import Foundation

class ASTOperation: Codable {

  let filePath: String
  let operationName: String
  let operationType: String
  let rootType: String // what's the difference here?
  let variables: [ASTOperationVariable]
  let source: String
  let fields: [ASTField]
  let fragmentSpreads: [String]
  let inlineFragments: [ASTInlineFragment]
  let sourceWithFragments: String
  let operationId: String?
}

class ASTOperationVariable: Codable {
  let name: String
  let type: String
}
