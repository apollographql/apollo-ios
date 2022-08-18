/// A protocol that a generated GraphQL schema should conform to.
///
/// The generated schema is the source of information about the generated types in the schema.
/// It is used to map each object in a `GraphQLResponse` to the ``Object`` type representing the
/// response object.
///
/// The generated schema also provides an entry point for customizing the cache key resolution
/// for the types in the schema, which is used by `NormalizedCache` mechanisms.
public protocol SchemaConfiguration {
  /// Maps each object in a `GraphQLResponse` to the ``Object`` type representing the
  /// response object.
  ///
  /// > Note: This function will be generated by the code generation engine. You should never
  /// alter the generated implementation or implement this function manually.
  ///
  /// - Parameter typename: The value of the `__typename` field of the response object.
  /// - Returns: An ``Object`` type representing the response object if the type is known to the
  /// schema. If the schema does not include a known ``Object`` with the given ``Object/typename``,
  /// returns `nil`.
  static func objectType(forTypename typename: String) -> Object?

  /// The entry point for configuring the cache key resolution
  /// for the types in the schema, which is used by `NormalizedCache` mechanisms.
  ///
  /// The default implementation always returns `nil`, disabling all cache normalization.
  ///
  /// > Note: This function should be implemented in an extension on your generated
  /// ``SchemaConfiguration`` to provide custom cache key resolution functionality.
  /// Your implementation extension must be in a seperate file from the generated,
  /// ``SchemaConfiguration`` or it will be overwritten on subsequent code generation executions.
  ///
  /// - Parameters:
  ///   - type: The ``Object`` type of the response `object`.
  ///   - object: The response object to resolve the cache key for.
  ///     Represented as a ``JSONObject`` dictionary.
  /// - Returns: A ``CacheKeyInfo`` describing the computed cache key for the response object.
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo?
}

extension SchemaConfiguration {

  @inlinable public static func cacheKeyInfo(
    for type: Object,
    object: JSONObject
  ) -> CacheKeyInfo? {    
    return nil
  }

  /// A convenience function for getting the ``Object`` type representing a response object.
  ///
  /// Calls the ``objectType(forTypename:)`` function with the value of the objects `__typename`
  /// field.
  ///
  /// - Parameter object: A ``JSONObject`` dictionary representing an object in a GraphQL response.
  /// - Returns: An ``Object`` type representing the response object if the type is known to the
  /// schema. If the schema does not include a known ``Object`` with the given ``Object/typename``,
  /// returns `nil`.
  @inlinable public static func graphQLType(for object: JSONObject) -> Object? {
    guard let typename = object["__typename"] as? String else {
      return nil
    }
    return objectType(forTypename: typename)
  }

  /// Resolves the ``CacheReference`` for an object in a GraphQL response to be used by
  /// `NormalizedCache` mechanisms.
  ///
  /// Maps the type of the `object` using the ``graphQLType(for:)`` function, then gets the
  /// ``CacheKeyInfo`` for the `object` using the ``cacheKeyInfo(for:object:)-3wf90`` function.
  /// Finally, this function transforms the ``CacheKeyInfo`` into the correct ``CacheReference``
  /// for the `NormalizedCache`.
  ///
  /// - Parameter object: A ``JSONObject`` dictionary representing an object in a GraphQL response.
  /// - Returns: The ``CacheReference`` for the `object` to be used by
  /// `NormalizedCache` mechanisms.
  @inlinable public static func cacheKey(for object: JSONObject) -> CacheReference? {
    guard let type = graphQLType(for: object),
          let info = cacheKeyInfo(for: type, object: object) else {
      return nil
    }
    return CacheReference("\(info.uniqueKeyGroupId ?? type.typename):\(info.key)")
  }
}
