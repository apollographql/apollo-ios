/// A structure that wraps the underlying data used by ``SelectionSet``s.
public struct DataDict: Hashable {
  #warning("TODO: Finish documentation here")
  /// A type representing the underlying data for a `SelectionSet`.
  ///
  /// - Warning: This is not identical to the JSON response from a GraphQL network request.
  /// The data should be normalized for consumption by a ``SelectionSet``. This means:
  ///   1. Values for entity fields are represented by ``DataDict`` values
  ///   2. Custom scalars are serialized and converted to their concrete types.
  ///   3. Inclusion conditions and type conditions **TODO**
  ///
  /// The process of converting a JSON response into ``SelectionSetData`` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper`. This can be performed manually
  /// by using **TODO**.
  public typealias SelectionSetData = [String: AnyHashable]

  public let _objectType: Object?
  public var _data: SelectionSetData
  public let _variables: GraphQLOperation.Variables?

  public init(
    objectType: Object?,
    data: SelectionSetData,
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
    get { T.init(_fieldData: _data[key]) }
    set { _data[key] = newValue._fieldData }
    _modify {
      var value = T.init(_fieldData: _data[key])
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
  ///
  /// The `_fieldData` should be the underlying `DataDict` for an entity value.
  /// This is represented as `AnyHashable` because for `Optional` and `Array` you will have an
  /// `Optional<DataDict>` and `[DataDict]` respectively.
  init(_fieldData: AnyHashable?)
  var _fieldData: AnyHashable { get }
}

extension SelectionSet {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?) {
    guard let data = data as? DataDict else {
      fatalError("\(Self.self) expected DataDict for entity, got \(type(of: data)).")
    }

    self.init(_dataDict: data)
  }

  @inlinable public var _fieldData: AnyHashable { __data }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?) {
    guard case let .some(data) = data else {
      self = .none
      return
    }
    self = .some(Wrapped.init(_fieldData: data))
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}

extension Array: SelectionSetEntityValue where Element: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?) {
    guard let data = data as? [AnyHashable?] else {
      fatalError("\(Self.self) expected list of data for entity.")
    }
    self = data.map { Element.init(_fieldData:$0?.base as? AnyHashable) }
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}
