#if !COCOAPODS
@_exported @testable import ApolloAPI
#endif
import Foundation

@dynamicMemberLookup
public class Mock<O: MockObject>: AnyMock, Hashable {

  public var _data: [String: AnyHashable]

  public init() {
    _data = ["__typename": O.objectType.typename]
  }

  public var __typename: String { _data["__typename"] as! String }

  public subscript<T: AnyScalarType & Hashable>(dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>) -> T? {
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
      _data[field.key.description] = (newValue as? AnyHashable)
    }
  }

  public subscript<T: MockFieldValue>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<Array<T>>>
  ) -> [T.MockValueCollectionType.Element]? {
    get {
      let field = O._mockFields[keyPath: keyPath]
      return _data[field.key.description] as? [T.MockValueCollectionType.Element]
    }
    set {
      let field = O._mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue?._unsafelyConvertToMockValue()
    }
  }

  public var _selectionSetMockData: JSONObject {
    _data.mapValues {
      if let mock = $0 as? AnyMock {
        return mock._selectionSetMockData
      }
      if let mockArray = $0 as? [AnyMock?] {
        return mockArray.map(\.?._selectionSetMockData)
      }
      return $0
    }
  }

  // MARK: Hashable

  public static func ==(lhs: Mock<O>, rhs: Mock<O>) -> Bool {
    lhs._data == rhs._data    
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data)
  }
}

// MARK: - Selection Set Conversion

public extension SelectionSet {
  static func from<O: MockObject>(
    _ mock: Mock<O>,
    withVariables variables: GraphQLOperation.Variables? = nil
  ) -> Self {
    Self.init(_dataDict: DataDict(
      objectType: O.objectType,
      data: mock._selectionSetMockData,
      variables: variables)
    )
  }
}

// MARK: - Helper Protocols

public protocol AnyMock {
  var _selectionSetMockData: JSONObject { get }
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

extension Optional: MockFieldValue where Wrapped: MockFieldValue {
  public typealias MockValueCollectionType = Array<Optional<Wrapped.MockValueCollectionType.Element>>
}

extension Array: MockFieldValue where Array.Element: MockFieldValue {
  public typealias MockValueCollectionType = Array<Element.MockValueCollectionType>
}

fileprivate extension Array {
  func _unsafelyConvertToMockValue() -> [AnyHashable?] {
    map { element in
      switch element {
      case let element as AnyHashable:
        return element

      case let innerArray as Array<Any>:
        return innerArray._unsafelyConvertToMockValue()

      default:
        return nil
      }
    }
  }
}
