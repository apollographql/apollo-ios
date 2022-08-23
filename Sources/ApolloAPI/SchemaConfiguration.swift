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
  /// - Parameters:
  ///   - type: The ``Object`` type of the response `object`.
  ///   - object: The response object to resolve the cache key for.
  ///     Represented as a ``JSONObject`` dictionary.
  /// - Returns: A ``CacheKeyInfo`` describing the computed cache key for the response object.
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo?
}
