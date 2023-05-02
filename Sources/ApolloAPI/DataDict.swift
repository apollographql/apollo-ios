/// A structure that wraps the underlying data for a ``SelectionSet``.
public struct DataDict: Hashable {
  @usableFromInline var _storage: _Storage

  /// The underlying data for a `SelectionSet`.
  ///
  /// - Warning: This is not identical to the JSON response from a GraphQL network request.
  /// The data should be normalized for consumption by a ``SelectionSet``. This means:
  ///
  /// * Values for entity fields are represented by ``DataDict`` values
  /// * Custom scalars are serialized and converted to their concrete types.
  ///
  /// The process of converting a JSON response into ``SelectionSetData`` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper`. This can be performed manually
  /// by using `SelectionSet.init(data: JSONObject, variables: GraphQLOperation.Variables?)` in
  /// the `Apollo` library.
  @inlinable public var _data: [String: AnyHashable] {
    get { _storage.data }
    set {
      if !isKnownUniquelyReferenced(&_storage) {
        _storage = _storage.copy()
      }
      _storage.data = newValue
    }
  }

  /// The set of fragments types that are fulfilled by the data of the ``SelectionSet``.
  ///
  /// During GraphQL execution, the fragments which have had their selections executed are tracked.
  /// This allows conversion of a ``SelectionSet`` to its fragment models to be done safely.
  ///
  /// Each `ObjectIdentifier` in the set corresponds to a specific `SelectionSet` type.
  @inlinable public var _fulfilledFragments: Set<ObjectIdentifier> {
    _storage.fulfilledFragments
  }

  public init(
    data: [String: AnyHashable],
    fulfilledFragments: Set<ObjectIdentifier>
  ) {
    self._storage = .init(data: data, fulfilledFragments: fulfilledFragments)
  }

  @inlinable public subscript<T: AnyScalarType & Hashable>(_ key: String) -> T {
    get {
#if swift(>=5.4)
        _data[key] as! T
#else
        _data[key]?.base as! T
#endif
    }
    set {
      _data[key] = newValue
    }
    _modify {
      var value = _data[key] as! T
      defer { _data[key] = value }
      yield &value
    }
  }
  
  @inlinable public subscript<T: SelectionSetEntityValue>(_ key: String) -> T {
    get { T.init(_fieldData: _data[key]) }
    set {
      _data[key] = newValue._fieldData
    }
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
    let id = ObjectIdentifier(T.self)
    return _fulfilledFragments.contains(id)
  }

  @usableFromInline func fragmentsAreFulfilled(_ types: [any SelectionSet.Type]) -> Bool {
    let typeIds = types.lazy.map(ObjectIdentifier.init)
    return _fulfilledFragments.isSuperset(of: typeIds)
  }

  // MARK: - DataDict._Storage
  @usableFromInline class _Storage: Hashable {
    @usableFromInline var data: [String: AnyHashable]
    @usableFromInline let fulfilledFragments: Set<ObjectIdentifier>

    init(
      data: [String: AnyHashable],
      fulfilledFragments: Set<ObjectIdentifier>
    ) {
      self.data = data
      self.fulfilledFragments = fulfilledFragments
    }

    @usableFromInline static func ==(lhs: DataDict._Storage, rhs: DataDict._Storage) -> Bool {
      lhs.data == rhs.data &&
      lhs.fulfilledFragments == rhs.fulfilledFragments
    }

    @usableFromInline func hash(into hasher: inout Hasher) {
      hasher.combine(data)
      hasher.combine(fulfilledFragments)
    }

    @usableFromInline func copy() -> _Storage {
      _Storage(data: self.data, fulfilledFragments: self.fulfilledFragments)
    }
  }
}



// MARK: Value Conversion Helpers

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
    guard let dataDict = data as? DataDict else {
      fatalError("\(Self.self) expected DataDict for entity, got \(type(of: data)).")
    }
    self.init(_dataDict: dataDict)
  }

  @inlinable public var _fieldData: AnyHashable { __data }
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
    self = data.map {
#if swift(>=5.4)
        Element.init(_fieldData:$0)
#else
        Element.init(_fieldData:$0?.base as? AnyHashable)
#endif
    }
  }

  @inlinable public var _fieldData: AnyHashable { map(\._fieldData) }
}
