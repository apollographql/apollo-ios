/// An protocol for a struct that represents a GraphQL Input Object.
///
/// - See: [GraphQLSpec - Input Objects](https://spec.graphql.org/draft/#sec-Input-Objects)
public protocol InputObject:
  GraphQLOperationVariableValue, _InitializableByDictionaryLiteralElements
{
  var data: InputDict { get }
  init(_ data: InputDict)
}

extension InputObject {
  public var jsonEncodableValue: JSONEncodable? { data.jsonEncodableValue }

  public init(dictionaryLiteral elements: (String, GraphQLOperationVariableValue)...) {
    self.init(elements)
  }

  public init(_ elements: [(String, GraphQLOperationVariableValue)]) {
    self.init(InputDict(.init(uniqueKeysWithValues: elements)))
  }
}


/// A structure that wraps the underlying data dictionary used by `InputObject`s.
@dynamicMemberLookup
public struct InputDict: GraphQLOperationVariableValue {

  private var data: [String: GraphQLOperationVariableValue]

  public init(_ data: [String: GraphQLOperationVariableValue] = [:]) {
    self.data = data
  }

  public var jsonEncodableValue: JSONEncodable? { data.jsonEncodableObject }

  public subscript<T: GraphQLOperationVariableValue>(dynamicMember key: StaticString) -> T {
    get { data[key.description] as! T }
    set { data[key.description] = newValue }
  }

}
