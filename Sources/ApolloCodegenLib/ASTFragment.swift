import Foundation

/// A reusable fragment to generate code for
struct ASTFragment: Codable, Equatable {
  /// The primary type the fragment is defined on
  let typeCondition: String
  
  /// All possible types that fragment could represent, if for instance the primary type is a Union or an Interface.
  let possibleTypes: [String]
  
  /// The name of the fragment
  let fragmentName: String
  
  /// The full file path to the file where this fragment was defined on the filesystem where the AST was generated.
  let filePath: String
  
  /// The raw string source of the fragment
  let source: String
  
  /// The fields requested in this fragment
  let fields: [ASTField]
  
  /// Names of fragments referenced at this level.
  let fragmentSpreads: [String]
  
  /// Fragments defined inline at this level
  let inlineFragments: [ASTInlineFragment]
}

/// A fragment defined inline on a particular object type such as `... on Droid { name }`
struct ASTInlineFragment: Codable, Equatable {
  /// The primary type the fragment is defined on
  let typeCondition: String
  
  /// All possible types that fragment could represent, if for instance the primary type is a Union or an Interface.
  let possibleTypes: [String]
  
  /// The fields requested in this fragment
  let fields: [ASTField]
  
  /// The names of any named fragments at this level of the fragment.
  let fragmentSpreads: [String]
}
