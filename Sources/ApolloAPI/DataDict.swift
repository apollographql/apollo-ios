import Foundation

/// A structure that wraps the underlying data for a ``SelectionSet``.
@_spi(Unsafe)
public struct DataDict: Hashable, @unchecked Sendable {
  public typealias FieldValue = any Sendable & Hashable

  @usableFromInline var _storage: _Storage

  /// The underlying data for a `SelectionSet`.
  ///
  /// - Warning: This is not identical to the JSON response from a GraphQL network request.
  /// The data should be normalized for consumption by a ``SelectionSet``. This means:
  ///
  /// * Values for entity fields are represented by ``DataDict`` values
  /// * Custom scalars are serialized and converted to their concrete types.
  ///
  /// The process of converting a JSON response into a ``SelectionSet`` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper`. This can be performed manually
  /// by using `SelectionSet.init(data: JSONObject, variables: GraphQLOperation.Variables?)` in
  /// the `Apollo` library.
  @inlinable public var _data: [String: FieldValue] {
    get { _storage.data }
    set {
      // Ensure we check `isKnownUniquelyReferenced` on a unique variable reference to the `_storage`.
      // See https://forums.swift.org/t/isknownuniquelyreferenced-thread-safety/22933 for details.
      var storage = _storage
      if !isKnownUniquelyReferenced(&storage) {
        storage = storage.copy()
      }
      storage.data = newValue
      _storage = storage
    }
    _modify {
      // Ensure we check `isKnownUniquelyReferenced` on a unique variable reference to the `_storage`.
      // See https://forums.swift.org/t/isknownuniquelyreferenced-thread-safety/22933 for details.
      var storage = _storage
      if !isKnownUniquelyReferenced(&_storage) {
        storage = storage.copy()
      }
      var data = storage.data
      defer {
        storage.data = data
        _storage = storage
      }
      yield &data
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

  /// The set of fragments that have not yet been fulfilled and will be delivered in a future
  /// response.
  ///
  /// Each `ObjectIdentifier` in the set corresponds to a specific `SelectionSet` type.
  @inlinable public var _deferredFragments: Set<ObjectIdentifier> {
    _storage.deferredFragments
  }

  public init(
    data: [String: FieldValue],
    fulfilledFragments: Set<ObjectIdentifier>,
    deferredFragments: Set<ObjectIdentifier> = []
  ) {
    self._storage = .init(
      data: data,
      fulfilledFragments: fulfilledFragments,
      deferredFragments: deferredFragments
    )
  }

  @inlinable public subscript<T: AnyScalarType & Hashable & Sendable>(_ key: String) -> T {
    get {
      return _data[key] as? AnyHashable as! T
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

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data)
  }

  public static func ==(lhs: DataDict, rhs: DataDict) -> Bool {
    AnySendableHashable.equatableCheck(lhs._data, rhs._data)
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
  @usableFromInline final class _Storage: Hashable {
    @usableFromInline var data: [String: FieldValue]
    @usableFromInline let fulfilledFragments: Set<ObjectIdentifier>
    @usableFromInline let deferredFragments: Set<ObjectIdentifier>

    init(
      data: [String: FieldValue],
      fulfilledFragments: Set<ObjectIdentifier>,
      deferredFragments: Set<ObjectIdentifier>
    ) {
      self.data = data
      self.fulfilledFragments = fulfilledFragments
      self.deferredFragments = deferredFragments
    }

    @usableFromInline static func ==(lhs: DataDict._Storage, rhs: DataDict._Storage) -> Bool {
      AnySendableHashable.equatableCheck(lhs.data, rhs.data) &&
      lhs.fulfilledFragments == rhs.fulfilledFragments &&
      lhs.deferredFragments == rhs.deferredFragments
    }

    @usableFromInline func hash(into hasher: inout Hasher) {
      hasher.combine(data)
      hasher.combine(fulfilledFragments)
      hasher.combine(deferredFragments)
    }

    @usableFromInline func copy() -> _Storage {
      _Storage(
        data: self.data,
        fulfilledFragments: self.fulfilledFragments,
        deferredFragments: self.deferredFragments
      )
    }
  }
}

// MARK: - Value Conversion Helpers

public protocol SelectionSetEntityValue: Sendable, Hashable {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// The `_fieldData` should be the underlying `DataDict` for an entity value.
  /// This is represented as `AnyHashable` because for `Optional` and `Array` you will have an
  /// `Optional<DataDict>` and `[DataDict]` respectively.
  @_spi(Unsafe)
  init(_fieldData: DataDict.FieldValue?)

  @_spi(Unsafe)
  var _fieldData: DataDict.FieldValue { get }
}

extension RootSelectionSet {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @_spi(Unsafe)
  @inlinable public init(_fieldData data: DataDict.FieldValue?) {
    guard let dataDict = data as? DataDict else {
      fatalError("\(Self.self) expected DataDict for entity, got \(type(of: data)).")
    }
    self.init(_dataDict: dataDict)
  }

  @_spi(Unsafe)
  public var _fieldData: DataDict.FieldValue { __data }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @_spi(Unsafe)
  @inlinable public init(_fieldData data: DataDict.FieldValue?) {
    guard case let .some(fieldData) = data.asNullable else {
      self = .none
      return
    }
    self = .some(Wrapped.init(_fieldData: fieldData))
  }

  @_spi(Unsafe)
  @inlinable public var _fieldData: DataDict.FieldValue {
    guard case let .some(data) = self else {
      return Self.none
    }
    return data._fieldData
  }
}

extension Array: SelectionSetEntityValue where Element: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @_spi(Unsafe)
  @inlinable public init(_fieldData data: DataDict.FieldValue?) {
    guard let data = data as? [DataDict.FieldValue?] else {
      fatalError("\(Self.self) expected list of data for entity.")
    }
    self = data.map {
      return Element.init(_fieldData:$0)
    }
  }

  @_spi(Unsafe)
  @inlinable public var _fieldData: DataDict.FieldValue {
    map { $0._fieldData } as DataDict.FieldValue
  }
}

extension NSArray: @retroactive @unchecked Sendable {}
