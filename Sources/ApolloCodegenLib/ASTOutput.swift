import Foundation

/// The top-level output of the AST generator
struct ASTOutput: Codable, Equatable {
  /// An array of all operations to generate code for.
  let operations: [ASTOperation]
  
  /// An array of all fragments to generate code for.
  let fragments: [ASTFragment]
  
  /// An array of all input types used
  let typesUsed: [ASTTypeUsed]
  
  /// An array of Union types used
  let unionTypes: [ASTUnionType]
  
  /// An array of Interface types used
  let interfaceTypes: [ASTInterfaceType]
}
