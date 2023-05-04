/// A protocol for an object used to provide custom configuration for a generated GraphQL schema.
///
/// A ``SchemaConfiguration`` provides an entry point for customizing the cache key resolution
/// for the types in the schema, which is used by `NormalizedCache` mechanisms.
public protocol SchemaConfiguration {
  /// The entry point for configuring the cache key resolution
  /// for the types in the schema, which is used by `NormalizedCache` mechanisms.
  ///
  /// The default generated implementation always returns `nil`, disabling all cache normalization.
  ///
  /// > Warning:
  /// Because cache key resolution is performed both on raw JSON (from a network response or cache
  /// hit) and `SelectionSet` model data (when writing to the cache directly), the underlying
  /// `object` will have different formats.
  ///
  /// This means that cache key resolution has a few notable limitations:
  /// 1. Computing cache keys from fields on nested objects is only allowed if the nested object
  /// does not have its own cache key. If the nested object has its own cache key, it will be
  /// normalized as a seperate cache entity. Cache keys for entities cannot be dependent on
  /// other entities.
  /// 2. When computing a cache key using a field of a ``CustomScalarType``, the underlying type of
  /// the value in the `object` dictionary will vary. It may be the raw JSON value for the scalar
  /// (when the source is a network response or cache hit) or the specific custom scalar type for
  /// the field (when the source is a `SelectionSet` model to write to the cache). When using a
  /// custom scalar field to compute a cache key, make sure to check the type and handle both of
  /// these possibilities.
  ///
  /// # See Also
  /// ``CacheKeyInfo``
  ///
  /// - Parameters:
  ///   - type: The ``Object`` type of the response `object`.
  ///   - object: The response object to resolve the cache key for.
  ///     Represented as a ``JSONObject`` dictionary.
  /// - Returns: A ``CacheKeyInfo`` describing the computed cache key for the response object.
  static func cacheKeyInfo(for type: Object, object: ObjectData) -> CacheKeyInfo?

}

public protocol ExecutionSourceDataTransformer {
  func transform(_ value: AnyHashable) -> (any ScalarType)?
  func transform(_ value: AnyHashable) -> ObjectData?
  func transform(_ value: AnyHashable) -> ListData?
}

public struct ObjectData {
  public let _transformer: ExecutionSourceDataTransformer
  public let _rawData: [String: AnyHashable]

  public init(
    _transformer: ExecutionSourceDataTransformer,
    _rawData: [String: AnyHashable]
  ) {
    self._transformer = _transformer
    self._rawData = _rawData
  }

  @inlinable public subscript(_ key: String) -> (any ScalarType)? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: String) -> ObjectData? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: String) -> ListData? {
    guard let value = _rawData[key] else { return nil }
    return _transformer.transform(value)
  }  

  #warning("TODO: add arguments")
//  subscript(_ key: String, withArguments: [String: AnyHashable]? = nil) -> AnyHashable? {
//    return nil
//  }
}

public struct ListData {
  public let _transformer: ExecutionSourceDataTransformer
  public let _rawData: [AnyHashable]

  public init(
    _transformer: ExecutionSourceDataTransformer,
    _rawData: [AnyHashable]
  ) {
    self._transformer = _transformer
    self._rawData = _rawData
  }

  @inlinable public subscript(_ key: Int) -> (any ScalarType)? {
    return _transformer.transform(_rawData[key])
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: Int) -> ObjectData? {
    return _transformer.transform(_rawData[key])
  }

  @_disfavoredOverload
  @inlinable public subscript(_ key: Int) -> ListData? {
    return _transformer.transform(_rawData[key])
  }
}
