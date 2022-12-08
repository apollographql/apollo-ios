import Foundation

/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct DataDict: Hashable {

  public var _data: JSONObject
  public let _variables: GraphQLOperation.Variables?

  public init(
    _ data: JSONObject,
    variables: GraphQLOperation.Variables?
  ) {
    self._data = data
    self._variables = variables
  }

  @inlinable public subscript<T: AnyScalarType & Hashable>(_ key: String) -> T {
    get { _data[key] as! T }
    set { _data[key] = newValue }
    _modify {
      var value = _data[key] as! T
      defer { _data[key] = value }
      yield &value
    }
  }
  
  @inlinable public subscript<T: SelectionSetEntityValue>(_ key: String) -> T {
    get { T.init(fieldData: _data[key], variables: _variables) }
    set { _data[key] = newValue._fieldData }
    _modify {
      var value = T.init(fieldData: _data[key], variables: _variables)
      defer { _data[key] = value._fieldData }
      yield &value
    }
  }

  @inlinable public func hash(into hasher: inout Hasher) {
    hasher.combine(_data)
    hasher.combine(_variables?._jsonEncodableValue?._jsonValue)
  }

  @inlinable public static func ==(lhs: DataDict, rhs: DataDict) -> Bool {
    lhs._data == rhs._data &&
    lhs._variables?._jsonEncodableValue?._jsonValue == rhs._variables?._jsonEncodableValue?._jsonValue
  }
}

public protocol SelectionSetEntityValue {
  init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?)
  var _fieldData: AnyHashable { get }
}

extension AnySelectionSet {
  @inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard let fieldData = fieldData as? JSONObject else {
      fatalError("\(Self.self) expected data for entity.")
    }
    self.init(data: DataDict(fieldData, variables: variables))
  }

  @inlinable public var _fieldData: AnyHashable { __data._data }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  @inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard case let .some(fieldData) = fieldData, !(fieldData is NSNull) else {
      self = .none
      return
    }
    self = .some(Wrapped.init(fieldData: fieldData, variables: variables))
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}

extension Array: SelectionSetEntityValue where Element: SelectionSetEntityValue {
  @inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard let fieldData = fieldData as? [AnyHashable?] else {
      fatalError("\(Self.self) expected list of data for entity.")
    }
    self = fieldData.map { Element.init(fieldData:$0, variables: variables) }
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}
