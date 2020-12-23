import Foundation
import JavaScriptCore

/// A GraphQL error.
public class GraphQLError: JavaScriptError {
  private lazy var source: GraphQLSource = self["source"]
  
  /// The source locations associated with this error.
  lazy var sourceLocations: [GraphQLSourceLocation] = {
    let locations: [JavaScriptObject] = self["locations"]
    
    if let nodes: [ASTNode] = self["nodes"] {
      // We have AST nodes, so this is a validation error.
      // Because errors can be associated with locations from different
      // source files, we ignore the `source` property and go through the
      // individual nodes instead.

      precondition(locations.count == nodes.count)
      
      return zip(locations, nodes).map { (location, node) in
        return GraphQLSourceLocation(filePath: node.filePath, lineNumber: location["line"].toInt(), columnNumber: location["column"].toInt())
      }
    } else {
      // We have no AST nodes, so this is a syntax error. Those only apply to a single source file,
      // so we can rely on the `source` property.
            
      return locations.map {
        GraphQLSourceLocation(filePath: source.filePath, lineNumber: $0["line"].toInt(), columnNumber: $0["column"].toInt())
      }
    }
  }()
  
  /// Log lines for this error in a format that allows Xcode to show errors inline at the correct location.
  /// See https://shazronatadobe.wordpress.com/2010/12/04/xcode-shell-build-phase-reporting-of-errors/
  var logLines: [String] {
    return sourceLocations.map {
      return [$0.filePath, String($0.lineNumber), "error", message ?? "?"].joined(separator: ":")
    }
  }
}

/// A GraphQL schema validation error.
public class GraphQLSchemaValidationError: JavaScriptError {
  lazy var validationErrors: [GraphQLError] = self["validationErrors"]
}
