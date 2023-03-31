/// A structure that wraps the underlying data used by ``SelectionSet``s.
public struct DataDict: Hashable {  
  /// A type representing the underlying data for a `SelectionSet`.
  ///
  /// - Warning: This is not identical to the JSON response from a GraphQL network request.
  /// The data should be normalized for consumption by a ``SelectionSet``. This means:
  ///
  /// * Values for entity fields are represented by ``DataDict`` values
  /// * Custom scalars are serialized and converted to their concrete types.
  /// * The `_data` dictionary includes a key `"_fulfilled"` that contains a `Set<ObjectIdentifier>`
  ///   containing all of the fragments that have been fulfilled for the object represented by
  ///   the `DataDict`.
  ///
  /// The process of converting a JSON response into ``SelectionSetData`` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper`. This can be performed manually
  /// by using `SelectionSet.init(data: JSONObject, variables: GraphQLOperation.Variables?)` in
  /// the `Apollo` library.
  public typealias SelectionSetData = [String: AnyHashable]

  public var _data: SelectionSetData

  public init(data: SelectionSetData) {
    self._data = data
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
  }

  @inlinable public static func ==(lhs: DataDict, rhs: DataDict) -> Bool {
    lhs._data == rhs._data
  }

  @usableFromInline func fragmentIsFulfilled<T: SelectionSet>(_ type: T.Type) -> Bool {
    guard let __fulfilledFragments = _data["__fulfilled"] as? Set<ObjectIdentifier> else {
      return false
    }
    let id = ObjectIdentifier(T.self)
    return __fulfilledFragments.contains(id)
  }

  @usableFromInline func fragmentsAreFulfilled(_ types: [any SelectionSet.Type]) -> Bool {
    guard let __fulfilledFragments = _data["__fulfilled"] as? Set<ObjectIdentifier> else {
      return false
    }
    let typeIds = types.lazy.map(ObjectIdentifier.init)
    return __fulfilledFragments.isSuperset(of: typeIds)
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

extension RootSelectionSet {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?) {
    guard let data = data as? DataDict.SelectionSetData else {
      fatalError("\(Self.self) expected JSONObject for entity, got \(type(of: data)).")
    }

    self.init(_dataDict: DataDict(data: data))
  }

  @inlinable public var _fieldData: AnyHashable { __data._data }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: AnyHashable?) {
    switch data {
      case .none:
        self = .none
      case .some(let hashable):
        if let optional = hashable.base as? Optional<AnyHashable>, optional == nil {
          self = .none
          return
        }
        self = .some(Wrapped.init(_fieldData: data))
    }
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
