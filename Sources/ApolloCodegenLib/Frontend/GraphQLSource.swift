import Foundation
import JavaScriptCore

/// A representation of source input to GraphQL parsing.
/// Corresponds to https://github.com/graphql/graphql-js/blob/master/src/language/source.js
public class GraphQLSource: JavaScriptObject {
  lazy var filePath: String = self["name"]
  
  lazy var body: String = self["body"]
}

/// Represents a location in a GraphQL source file.
public struct GraphQLSourceLocation {
  let filePath: String
  
  let lineNumber: Int
  let columnNumber: Int
}

/// A parsed GraphQL document.
public class GraphQLDocument: ASTNode {
  lazy var definitions: [ASTNode] = self["definitions"]
  
  required init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    super.init(jsValue, bridge: bridge)
    
    precondition(kind == "Document")
  }
}

/// An AST node.
public class ASTNode: JavaScriptObject {
  lazy var kind: String = self["kind"]
      
  private lazy var source: GraphQLSource = bridge.fromJSValue(self["loc"]["source"])
  lazy var filePath: String = source.filePath
}
