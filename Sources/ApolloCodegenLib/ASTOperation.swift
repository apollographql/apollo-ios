import Foundation

/// The representation of a single operation defined in a .graphql file.
struct ASTOperation: Codable, Equatable {
  
  /// The available types of operation
  enum OperationType: String, Codable {
    case mutation
    case query
    case subscription
  }
  
  /// A variable in an operation
  struct Variable: Codable, Equatable {
    /// The name of the variable
    let name: String
    
    /// The type of the variable
    let typeNode: ASTVariableType
  }

  /// The full file path to the file where this operation was defined on the filesystem where the AST was generated.
  let filePath: String
  
  /// The raw name of the operation
  let operationName: String
  
  /// The type of the operation
  let operationType: OperationType
  
  /// The name of the root type for this operation. Every graph can only have one type for each `OperationType`.
  let rootType: String
  
  /// The variables for this operation
  let variables: [ASTOperation.Variable]
  
  /// The string source of the operation.
  let source: String
  
  /// The immediate fields returned with this operation.
  let fields: [ASTField]
  
  /// Names of fragments referenced at this level.
  let fragmentSpreads: [String]
  
  /// Fragments defined inline at this level
  let inlineFragments: [ASTInlineFragment]
  
  /// Names of any fragments referenced wtihin this operation at any level
  let fragmentsReferenced: [String]
  
  /// The full source with all fragments appended.
  let sourceWithFragments: String
  
  /// [optional] The calculated ID for the operation. Will only be generated if `operationIDsURL` is passed into `ApolloCodegenOptions`.`
  let operationId: String?
}
