/// An protocol for a struct that represents a GraphQL Input Object.
///
/// # See Also
/// [GraphQLSpec - Input Objects](https://spec.graphql.org/draft/#sec-Input-Objects)
public protocol InputObject: GraphQLOperationVariableValue, JSONEncodable, Hashable {
  var __data: InputDict { get }
}

extension InputObject {
  public var _jsonValue: JSONValue { jsonEncodableValue?._jsonValue }
  public var jsonEncodableValue: (any JSONEncodable)? { __data._jsonEncodableValue }

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

  public var _jsonEncodableValue: (any JSONEncodable)? { data._jsonEncodableObject }

  public subscript<T: GraphQLOperationVariableValue>(dynamicMember key: StaticString) -> T {
    get { data[key.description] as! T }
    set { data[key.description] = newValue }
  }

  public static func == (lhs: InputDict, rhs: InputDict) -> Bool {
    lhs.data._jsonEncodableValue?._jsonValue == rhs.data._jsonEncodableValue?._jsonValue
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(data._jsonEncodableValue?._jsonValue)
  }

}
