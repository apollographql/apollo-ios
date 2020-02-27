import Foundation

class ASTOperation: Codable {
  enum OperationType: String, Codable {
    case mutation
    case query
    case subscription
  }
  
  enum RootType: String, Codable { // what's the difference here?
    case Mutation
    case Query
    case Subscription
  }

  let filePath: String
  let operationName: String
  let operationType: OperationType
  let rootType: RootType
  let variables: [ASTOperationVariable]
  let source: String
  let fields: [ASTField]
  let fragmentSpreads: [String]
  let inlineFragments: [ASTInlineFragment]
  let fragmentsReferenced: [String]
  let sourceWithFragments: String
  let operationId: String?
}

class ASTOperationVariable: Codable {
  let name: String
  let type: String
}
