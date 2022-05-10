import ApolloAPI

@dynamicMemberLookup
public class Mock<O: Mockable>: AnyMock {
  public var _data: JSONEncodableDictionary

  public init() {
    _data = ["__typename": O.__typename.description]
  }

  public var __typename: String { _data["__typename"] as! String }

  public subscript<T: JSONEncodable>(dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>) -> T? {
    get {
      let field = O.__mockFields[keyPath: keyPath]
      return _data[field.key.description] as? T
    }
    set {
      let field = O.__mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue
    }
  }

//  public subscript<T: MockFieldValue>(
//    dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>
//  ) -> T.MockValueType? {
//    get {
//      let field = O.__mockFields[keyPath: keyPath]
//      return _data[field.key.description] as? T.MockValueType
//    }
//    set {
//      let field = O.__mockFields[keyPath: keyPath]
//      _data[field.key.description] = newValue
//    }
//  }

  public subscript<T: Mockable>(dynamicMember keyPath: KeyPath<O.MockFields, Field<T>>) -> Mock<T>? {
    get {
      let field = O.__mockFields[keyPath: keyPath]
      return _data[field.key.description] as? Mock<T>
    }
    set {
      let field = O.__mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue
    }
  }

  public subscript<T: Mockable, I: Interface>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<I>>
  ) -> Mock<T>? {
    get {
      let field = O.__mockFields[keyPath: keyPath]
      return _data[field.key.description] as? Mock<T>
    }
    set {
      let field = O.__mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue
    }
  }

  public subscript<S: Sequence, MS: Sequence & JSONEncodable>(
    dynamicMember keyPath: KeyPath<O.MockFields, Field<S>>
  ) -> MS? where S.Element: MockFieldValue, MS.Element == S.Element.MockValueType {
    get {
      let field = O.__mockFields[keyPath: keyPath]
      return _data[field.key.description] as? MS
    }
    set {
      let field = O.__mockFields[keyPath: keyPath]
      _data[field.key.description] = newValue
    }
  } 

  // MARK: JSONEncodable

  public var jsonValue: JSONValue { "" } // TODO 

}

public protocol AnyMock: JSONEncodable {}

public protocol Mockable: Object, MockFieldValue {
  associatedtype MockFields
  associatedtype MockValueType = Mock<Self>

  static var __mockFields: MockFields { get }
}

public protocol MockFieldValue {
  associatedtype MockValueType: JSONEncodable
}


//extension Object: MockFieldValue where Self: Mockable {
//  public typealias MockValueType = Mock<Self>
//}

//public struct AnyMockList: JSONEncodable, ExpressibleByArrayLiteral {
//  let list: [AnyMock]
//
//  public init(arrayLiteral elements: AnyMock...) {
//    self.list = elements
//  }
//
//  public var jsonValue: JSONValue { "" }
//}
//
//extension Interface: MockFieldValue {
//  public typealias MockValueType = AnyMockList
//}

extension Array: AnyMock where Array.Element == AnyMock {}
extension Array: MockFieldValue where Array.Element: MockFieldValue & JSONEncodable {
  public typealias MockValueType = Array<Element.MockValueType>
}
