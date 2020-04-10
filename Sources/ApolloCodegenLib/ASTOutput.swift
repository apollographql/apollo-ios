import Foundation

/// The top-level output of the AST generator
struct ASTOutput: Codable, Equatable {
  /// An array of all operations to generate code for.
  let operations: [ASTOperation]
  
  /// An array of all fragments to generate code for.
  let fragments: [ASTFragment]
  
  /// An array of "all" types used <-- TODO: Figure out why some are not in here
  let typesUsed: [ASTTypeUsed]
}
