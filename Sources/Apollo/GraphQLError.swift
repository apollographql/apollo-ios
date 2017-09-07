import Foundation

/// Represents an error encountered during the execution of a GraphQL operation.
///
///  - SeeAlso: [The Response Format section in the GraphQL specification](https://facebook.github.io/graphql/#sec-Response-Format)
public struct GraphQLError: Error {
  private let object: JSONObject
  
  init(_ object: JSONObject) {
    self.object = object
  }
  
  init(_ message: String) {
    self.init(["message": message])
  }
  
  /// GraphQL servers may provide additional entries as they choose to produce more helpful or machine‐readable errors.
  public subscript(key: String) -> Any? {
    return object[key]
  }
  
  /// A description of the error.
  public var message: String {
    return self["message"] as! String
  }
  
  /// A list of locations in the requested GraphQL document associated with the error.
  public var locations: [Location]? {
    return (self["locations"] as? [JSONObject])?.map(Location.init)
  }
  
  /// Represents a location in a GraphQL document.
  public struct Location {
    /// The line number of a syntax element.
    public let line: Int
    /// The column number of a syntax element.
    public let column: Int
    
    init(_ object: JSONObject) {
      line = object["line"] as! Int
      column = object["column"] as! Int
    }
  }
}

extension GraphQLError: CustomStringConvertible {
  public var description: String {
    return self.message
  }
}

extension GraphQLError: LocalizedError {
  public var errorDescription: String? {
    return description
  }
}
