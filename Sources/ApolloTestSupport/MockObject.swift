@_exported import ApolloAPI
import Foundation

@dynamicMemberLookup
public class Mock<O: Mockable>: AnyMock, JSONEncodable, Hashable {

  public var _data: JSONEncodableDictionary

  public init() {
    _data = ["__typename": O.__typename.description]
  }

  public var __typename: String { _data["__typename"] as! String }

  public subscript<T: AnyScalarType>(dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>) -> T? {
    get {
      let field = O.__mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T
    }
    set {
      let field = O.__mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue
    }
  }

  public subscript<T: MockFieldValue>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>
  ) -> T.MockValueCollectionType.Element? {
    get {
      let field = O.__mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T.MockValueCollectionType.Element
    }
    set {
      let field = O.__mockFields[keyPath: keyPath]
      _data[field.key.description] = (newValue as! JSONEncodable)
    }
  }

  // MARK: JSONEncodable

  public var _jsonObject: JSONObject { _data.jsonObject }
  public var jsonValue: JSONValue { _jsonObject }

  // MARK: Equatable

  public static func ==(lhs: Mock<O>, rhs: Mock<O>) -> Bool {
    NSDictionary(dictionary: lhs._data).isEqual(to: rhs._data)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data.asAnyHashable)
  }
}

// MARK: - Selection Set Conversion

public extension SelectionSet {
  static func from(
    _ mock: AnyMock,
    withVariables variables: GraphQLOperation.Variables? = nil
  ) -> Self {
    Self.init(data: DataDict(mock._jsonObject, variables: variables))
  }
}

// MARK: - Helper Protocols

public protocol AnyMock: JSONEncodable {
  var _jsonObject: JSONObject { get }
}

public protocol Mockable: Object, MockFieldValue {
  associatedtype MockFields
  associatedtype MockValueCollectionType = Array<Mock<Self>>

  static var __mockFields: MockFields { get }
}

public protocol MockFieldValue {
  associatedtype MockValueCollectionType: Collection
}

extension Interface: MockFieldValue {
  public typealias MockValueCollectionType = Array<AnyMock>
}

extension Array: MockFieldValue where Array.Element: MockFieldValue {
  public typealias MockValueCollectionType = Array<Element.MockValueCollectionType>
}

extension Optional: MockFieldValue where Wrapped: MockFieldValue {
  public typealias MockValueCollectionType = Array<Optional<Wrapped.MockValueCollectionType.Element>>
}
