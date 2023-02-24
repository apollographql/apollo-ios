/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct DataDict: Hashable {

  public let _objectType: Object?
  public var _data: JSONObject
  public let _variables: GraphQLOperation.Variables?

  public init(
    objectType: Object?,
    data: JSONObject,
    variables: GraphQLOperation.Variables? = nil
  ) {
    self._data = data
    self._objectType = objectType
    self._variables = variables
  }

  @inlinable public subscript<T: AnyScalarType & Hashable>(_ key: String) -> T {
    get { _data[key]?.base as! T }
    set { _data[key] = newValue }
    _modify {
      var value = _data[key] as! T
      defer { _data[key] = value }
      yield &value
    }
  }
  
  @inlinable public subscript<T: SelectionSetEntityValue>(_ key: String) -> T {
    get { T.init(_fieldData: _data[key], variables: _variables) }
    set { _data[key] = newValue._fieldData }
    _modify {
      var value = T.init(_fieldData: _data[key], variables: _variables)
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
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  init(_fieldData: AnyHashable?, variables: GraphQLOperation.Variables?)
  var _fieldData: AnyHashable { get }
}

extension SelectionSet {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard let data = data as? JSONObject else {
      fatalError("\(Self.self) expected data for entity.")
    }

    self.init(unsafeData: data, variables: variables)
  }

  @inlinable public var _fieldData: AnyHashable { __data._data }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard case let .some(data) = data else {
      self = .none
      return
    }
    self = .some(Wrapped.init(_fieldData: data, variables: variables))
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}

extension Array: SelectionSetEntityValue where Element: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard let data = data as? [AnyHashable?] else {
      fatalError("\(Self.self) expected list of data for entity.")
    }
    self = data.map { Element.init(_fieldData:$0?.base as? AnyHashable, variables: variables) }
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}
