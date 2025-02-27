import Foundation

/// A structure that wraps the underlying data for a ``SelectionSet``.
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

#warning("TODO: Should this be comparing to storage? Or just the data values? Should we implement the equality checks with only selected values?")
//  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data)
  }

//  @inlinable
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

// MARK: - Null Value Definition
extension DataDict {
  /// A common value used to represent a null value in a `DataDict`.
  ///
  /// This value can be cast to `NSNull` and will bridge automatically.
  #warning("TODO: Kill this?")
  public static let _NullValue: NSNull = NSNull()

  /// Indicates if `AnyHashable` can be coerced via casting into its underlying type.
  ///
  /// In iOS versions 14.4 and lower, `AnyHashable` coercion does not work. On these platforms,
  /// we need to do some additional unwrapping and casting of the values to avoid crashes and other
  /// run time bugs.
  #warning("TODO: Kill this?")
  public static let _AnyHashableCanBeCoerced: Bool = {
    if #available(iOS 14.5, *) {
      return true
    } else {
      return false
    }
  }()

}

// MARK: - Value Conversion Helpers

public protocol SelectionSetEntityValue: Sendable, Hashable {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  ///
  /// The `_fieldData` should be the underlying `DataDict` for an entity value.
  /// This is represented as `AnyHashable` because for `Optional` and `Array` you will have an
  /// `Optional<DataDict>` and `[DataDict]` respectively.
  init(_fieldData: DataDict.FieldValue?)
  var _fieldData: DataDict.FieldValue { get }
}

extension RootSelectionSet {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  @inlinable public init(_fieldData data: DataDict.FieldValue?) {
    guard let dataDict = data as? DataDict else {
      fatalError("\(Self.self) expected DataDict for entity, got \(type(of: data)).")
    }
    self.init(_dataDict: dataDict)
  }

  @inlinable public var _fieldData: DataDict.FieldValue { __data }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  /// - Warning: This function is not supported for external use.
  /// Unsupported usage may result in unintended consequences including crashes.
  public init(_fieldData data: DataDict.FieldValue?) {
    guard !data.isRecursivelyNil(), let data = data, !(data is NSNull) else {
      self = .none
      return
    }
    self = .some(Wrapped.init(_fieldData: data))
  }

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
  @inlinable public init(_fieldData data: DataDict.FieldValue?) {
    guard let data = data as? [DataDict.FieldValue?] else {
      fatalError("\(Self.self) expected list of data for entity.")
    }
    self = data.map {
      return Element.init(_fieldData:$0)
    }
  }

  @inlinable public var _fieldData: DataDict.FieldValue {
    map { $0._fieldData } as DataDict.FieldValue
  }
}
