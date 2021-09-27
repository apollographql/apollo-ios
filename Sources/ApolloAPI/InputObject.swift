/// An protocol for a struct that represents a GraphQL Input Object.
///
/// - See: [GraphQLSpec - Input Objects](https://spec.graphql.org/draft/#sec-Input-Objects)
public protocol InputObject: GraphQLOperationVariableValue {
  var dict: InputDict { get }
}

extension InputObject {
  public var jsonEncodableValue: JSONEncodable? { dict.jsonEncodableValue }
}

/// A structure that wraps the underlying data dictionary used by `InputObject`s.
public struct InputDict: GraphQLOperationVariableValue {

  private var data: [String: GraphQLOperationVariableValue]

  public init(_ data: [String: GraphQLOperationVariableValue] = [:]) {
    self.data = data
  }

  public var jsonEncodableValue: JSONEncodable? { data.jsonEncodableObject }

  public subscript<T: GraphQLOperationVariableValue>(_ key: String) -> T {
    data[key] as! T
  }

  public subscript<T: GraphQLOperationVariableValue>(_ key: String) -> T? {
    get { data[key] as? T }
    set { data[key] = newValue }
  }

  public subscript<T: GraphQLOperationVariableValue>(_ key: String) -> [T] {
    data[key] as! [T]
  }

  public subscript<T: GraphQLOperationVariableValue>(_ key: String) -> [T]? {
    data[key] as? [T]
  }

  public subscript<T: GraphQLOperationVariableValue>(_ key: String) -> [[T]] {
    data[key] as! [[T]]
  }

  public subscript<T: GraphQLOperationVariableValue>(_ key: String) -> [[T]]? {
    data[key] as? [[T]]
  }

}
