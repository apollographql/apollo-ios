/// An protocol for a struct that represents a GraphQL Input Object.
///
/// # See Also
/// [GraphQLSpec - Input Objects](https://spec.graphql.org/draft/#sec-Input-Objects)
public protocol InputObject: GraphQLOperationVariableValue, JSONEncodable, Hashable {
  @_spi(Unsafe)
  var __data: InputDict { get }
}

extension InputObject {
  @_spi(Internal)
  public var _jsonValue: JSONValue { __data.data._jsonEncodableObject._jsonValue }
  @_spi(Internal)
  public var jsonEncodableValue: (any JSONEncodable)? { __data._jsonEncodableValue }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__data == rhs.__data
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(__data)
  }
}

/// A structure that wraps the underlying data dictionary used by `InputObject`s.
@_spi(Unsafe)
public struct InputDict: GraphQLOperationVariableValue, Hashable {

  fileprivate var data: [String: any GraphQLOperationVariableValue]

  public init(_ data: [String: any GraphQLOperationVariableValue] = [:]) {
    self.data = data
  }

  @_spi(Internal)
  public var _jsonEncodableValue: (any JSONEncodable)? { data._jsonEncodableObject }

  public subscript<T: GraphQLOperationVariableValue>(key: String) -> GraphQLNullable<T> {
    get {
      if let value = data[key] {
        return value as! GraphQLNullable<T>
      }

      return .none
    }
    set { data[key] = newValue }
  }

  @_disfavoredOverload
  public subscript<T: GraphQLOperationVariableValue>(key: String) -> T {
    get { data[key] as! T }
    set { data[key] = newValue }
  }

  @_disfavoredOverload
  public subscript<T: GraphQLOperationVariableValue>(key: String) -> T? {
    get {
      switch data[key] {
      case let .some(value) as GraphQLNullable<T>,
        let value as T:
        return value
        
      default:
        return nil
      }
    }
    set { data[key] = newValue ?? GraphQLNullable.none }
  }

  public static func == (lhs: InputDict, rhs: InputDict) -> Bool {
    AnyHashable(lhs.data._jsonEncodableObject._jsonValue) ==
    AnyHashable(rhs.data._jsonEncodableObject._jsonValue)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(data._jsonEncodableObject._jsonValue)
  }

}

public protocol OneOfInputObject: InputObject { }
