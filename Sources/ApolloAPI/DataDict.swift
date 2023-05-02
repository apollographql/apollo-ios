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
  #warning("TODO: documentation updates")
  public class _Storage: Hashable {
    @usableFromInline var data: [String: AnyHashable]
    @usableFromInline let fulfilledFragments: Set<ObjectIdentifier>

    public init(
      data: [String: AnyHashable],
      fulfilledFragments: Set<ObjectIdentifier>
    ) {
      self.data = data
      self.fulfilledFragments = fulfilledFragments
    }

    @inlinable public static func ==(lhs: DataDict._Storage, rhs: DataDict._Storage) -> Bool {
      lhs.data == rhs.data &&
      lhs.fulfilledFragments == rhs.fulfilledFragments
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(data)
      hasher.combine(fulfilledFragments)
    }

    fileprivate func copy() -> _Storage {
      _Storage(data: self.data, fulfilledFragments: self.fulfilledFragments)
    }
  }

  @usableFromInline var _storage: _Storage

  @inlinable public var _data: [String: AnyHashable] {
    get { _storage.data }
    set { _storage.data = newValue }
  }

  @inlinable public var _fulfilledFragments: Set<ObjectIdentifier> {
    _storage.fulfilledFragments
  }

  public init(
    data: [String: AnyHashable],
    fulfilledFragments: Set<ObjectIdentifier>
  ) {
    self._storage = .init(data: data, fulfilledFragments: fulfilledFragments)
  }

  public init(selectionSetData: _Storage) {
    self._storage = selectionSetData
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
      copyOnWriteIfNeeded()
      _data[key] = newValue
    }
    _modify {
      copyOnWriteIfNeeded()
      var value = _data[key] as! T
      defer { _data[key] = value }
      yield &value
    }
  }
  
  @inlinable public subscript<T: SelectionSetEntityValue>(_ key: String) -> T {
    get { T.init(_fieldData: _data[key]) }
    set {
      copyOnWriteIfNeeded()
      _data[key] = newValue._fieldData
    }
    _modify {
      copyOnWriteIfNeeded()
      var value = T.init(_fieldData: _data[key])
      defer { _data[key] = value._fieldData }
      yield &value
    }
  }

  @usableFromInline mutating func copyOnWriteIfNeeded() {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _storage.copy()
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
    return _storage.fulfilledFragments.contains(id)
  }

  @usableFromInline func fragmentsAreFulfilled(_ types: [any SelectionSet.Type]) -> Bool {
    let typeIds = types.lazy.map(ObjectIdentifier.init)
    return _storage.fulfilledFragments.isSuperset(of: typeIds)
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
