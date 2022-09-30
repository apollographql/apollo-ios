#if !COCOAPODS
@_exported import ApolloAPI
#endif
import Foundation

@dynamicMemberLookup
public class Mock<O: MockObject>: AnyMock, JSONEncodable, Hashable {

  public var _data: JSONEncodableDictionary

  public init() {
    _data = ["__typename": O.objectType.typename]
  }

  public var __typename: String { _data["__typename"] as! String }

  public subscript<T: AnyScalarType>(dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>) -> T? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T
    }
    set {
      let field = O._mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue
    }
  }

  public subscript<T: MockFieldValue>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>
  ) -> T.MockValueCollectionType.Element? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T.MockValueCollectionType.Element
    }
    set {
      let field = O._mockFields[keyPath: keyPath]
      _data[field.key.description] = (newValue as? (any JSONEncodable))
    }
  }

  // MARK: JSONEncodable

  public var _jsonObject: JSONObject { _data._jsonObject }
  public var _jsonValue: JSONValue { _jsonObject }

  // MARK: Hashable

  public static func ==(lhs: Mock<O>, rhs: Mock<O>) -> Bool {
    NSDictionary(dictionary: lhs._data).isEqual(to: rhs._data)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data._jsonValue)
  }
}

// MARK: - Selection Set Conversion

public extension SelectionSet {
  static func from(
    _ mock: any AnyMock,
    withVariables variables: GraphQLOperation.Variables? = nil
  ) -> Self {
    Self.init(data: DataDict(mock._jsonObject, variables: variables))
  }
}

// MARK: - Helper Protocols

public protocol AnyMock: JSONEncodable {
  var _jsonObject: JSONObject { get }
}

public protocol MockObject: MockFieldValue {
  associatedtype MockFields
  associatedtype MockValueCollectionType = Array<Mock<Self>>

  static var objectType: Object { get }
  static var _mockFields: MockFields { get }
}

public protocol MockFieldValue {
  associatedtype MockValueCollectionType: Collection
}

extension Interface: MockFieldValue {
  public typealias MockValueCollectionType = Array<AnyMock>
}

extension Union: MockFieldValue {
  public typealias MockValueCollectionType = Array<AnyMock>
}

extension Array: MockFieldValue where Array.Element: MockFieldValue {
  public typealias MockValueCollectionType = Array<Element.MockValueCollectionType>
}

extension Optional: MockFieldValue where Wrapped: MockFieldValue {
  public typealias MockValueCollectionType = Array<Optional<Wrapped.MockValueCollectionType.Element>>
}
