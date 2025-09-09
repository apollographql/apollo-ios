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
  /// Cache key resolution has a few notable quirks and limitations you should be aware of while
  /// implementing your cache key resolution function:
  ///
  /// 1. While the cache key for an object can use a field from another nested object, if the fields
  /// on the referenced object are changed in another operation, the cache key for the dependent
  /// object will not be updated. For nested objects that are not normalized with their own cache
  /// key, this will never occur, but if the nested object is an entity with its own cache key, it
  /// can be mutated independently. In that case, any other objects whose cache keys are dependent
  /// on the mutated entity will not be updated automatically. You must take care to update those
  /// entities manually with a cache mutation.
  ///
  /// 2. The `object` passed to this function represents data for an object in an specific operation
  /// model, not a type in your schema. This means that
  /// [aliased fields](https://spec.graphql.org/draft/#sec-Field-Alias) will be keyed on their
  /// alias name, not the name of the field on the schema type.
  ///
  /// 3. The `object` parameter of this function is an ``ObjectData`` struct that wraps the
  /// underlying object data. Because cache key resolution is performed both on raw JSON (from a
  /// network response) and `SelectionSet` model data (when writing to the cache directly),
  /// the underlying data will have different formats. The ``ObjectData`` wrapper is used to
  /// normalize this data to a consistent format in this context.
  ///
  /// # See Also
  /// ``CacheKeyInfo``
  ///
  /// - Parameters:
  ///   - type: The ``Object`` type of the response `object`.
  ///   - object: The response object to resolve the cache key for.
  ///     Represented as a ``ObjectData`` dictionary.
  /// - Returns: A ``CacheKeyInfo`` describing the computed cache key for the response object.
  static func cacheKeyInfo(for type: Object, object: ObjectData) -> CacheKeyInfo?
}
