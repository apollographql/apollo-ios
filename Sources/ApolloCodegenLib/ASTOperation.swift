import Foundation

class ASTOperation: Codable {
  enum OperationType: String, Codable {
    case mutation
    case query
    case subscription
  }

  /// The full file path to this file on the filesystem where the AST was generated.
  let filePath: String
  
  /// The raw name of the operation
  let operationName: String
  
  /// The type of the operation
  let operationType: OperationType
  
  /// The name of the root type for this operation. Every graph can only have one type for each `OperationType`.
  let rootType: String
  let variables: [ASTOperationVariable]
  
  /// The string source of the operation.
  let source: String
  
  /// The immediate fields returned with this operation.
  let fields: [ASTField]
  
  /// Names of fragments referenced at this level.
  let fragmentSpreads: [String]
  
  /// Fragments defined inline on a particuar object type such as `... on Droid`
  let inlineFragments: [ASTInlineFragment]
  
  /// Names of any fragments referenced wtihin this operation at any level
  let fragmentsReferenced: [String]
  
  /// The full source with all fragments appended.
  let sourceWithFragments: String
  
  /// [optional] The calculated ID for the operation. Will only be generated if `operationIDsURL` is passed into `ApolloCodegenOptions`.`
  let operationId: String?
}

/// A variable in an operation
class ASTOperationVariable: Codable {
  /// The name of the variable
  let name: String
  
  /// The type of the variable
  let type: ASTVariableType
}
