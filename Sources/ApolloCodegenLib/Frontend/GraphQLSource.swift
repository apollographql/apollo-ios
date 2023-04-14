import Foundation
import JXKit

/// A representation of source input to GraphQL parsing.
/// Corresponds to https://github.com/graphql/graphql-js/blob/master/src/language/source.js
public class GraphQLSource: JavaScriptObject {
  private(set) lazy var filePath: String = self["name"]

  private(set) lazy var body: String = self["body"]
}

/// Represents a location in a GraphQL source file.
public struct GraphQLSourceLocation {
  let filePath: String

  let lineNumber: Int
  let columnNumber: Int
}

// These classes correspond to the AST node types defined in
// https://github.com/graphql/graphql-js/blob/master/src/language/ast.js
// But since we don't need to access these directly, we haven't defined specific wrapper types except for
// `GraphQLDocument`.

/// An AST node.
public class ASTNode: JavaScriptObject {
  lazy var kind: String = self["kind"]

  private lazy var source: GraphQLSource = bridge.fromJXValue(self["loc"]["source"])
  private(set) lazy var filePath: String = source.filePath
}

/// A parsed GraphQL document.
public class GraphQLDocument: ASTNode {
  private(set) lazy var definitions: [ASTNode] = self["definitions"]

  required init(_ jsValue: JXValue, bridge: JavaScriptBridge) {
    super.init(jsValue, bridge: bridge)

    precondition(kind == "Document", "Expected GraphQL DocumentNode but found: \(jsValue)")
  }
}
