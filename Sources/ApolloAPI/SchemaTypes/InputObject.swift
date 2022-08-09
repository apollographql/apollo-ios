/// An protocol for a struct that represents a GraphQL Input Object.
///
/// # See Also
/// [GraphQLSpec - Input Objects](https://spec.graphql.org/draft/#sec-Input-Objects)
public protocol InputObject: GraphQLOperationVariableValue, JSONEncodable, Hashable {
  var __data: InputDict { get }
}

extension InputObject {
  public var jsonValue: JSONValue { jsonEncodableValue?.jsonValue }
  public var jsonEncodableValue: (any JSONEncodable)? { __data.jsonEncodableValue }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__data == rhs.__data
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(__data)
  }
}

/// A structure that wraps the underlying data dictionary used by `InputObject`s.
@dynamicMemberLookup
public struct InputDict: GraphQLOperationVariableValue, Hashable {

  private var data: [String: GraphQLOperationVariableValue]

  public init(_ data: [String: GraphQLOperationVariableValue] = [:]) {
    self.data = data
  }

  public var jsonEncodableValue: (any JSONEncodable)? { data.jsonEncodableObject }

  public subscript<T: GraphQLOperationVariableValue>(dynamicMember key: StaticString) -> T {
    get { data[key.description] as! T }
    set { data[key.description] = newValue }
  }

  public static func == (lhs: InputDict, rhs: InputDict) -> Bool {
    lhs.data.jsonEncodableValue?.jsonValue == rhs.data.jsonEncodableValue?.jsonValue
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(data.jsonEncodableValue?.jsonValue)
  }

}
