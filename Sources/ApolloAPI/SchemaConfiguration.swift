public protocol SchemaConfiguration {
  static func objectType(forTypename __typename: String) -> Object.Type?
}

extension SchemaConfiguration {
  public static func cacheKey(for data: JSONObject) -> CacheReference? {
    guard let __typename = data["__typename"] as? String,
          let keyString = cacheKeyString(for: data, withTypename: __typename) else {
      return nil
    }
    return CacheReference(keyString)
  }

  private static func cacheKeyString(
    for data: JSONObject,
    withTypename __typename: String
  ) -> String? {
    if let objectType = objectType(forTypename: __typename),
       let resolver = objectType.__cacheKeyProvider {
      return resolver.cacheReferenceString(for: data, typename: __typename)
    }

    if let unknownTypeMapper = self as? SchemaUnknownTypeCacheKeyProvider.Type,
       let resolver = unknownTypeMapper.cacheKeyProviderForUnknownType(withTypename: __typename,
                                                                       data: data) {
      return resolver.cacheReferenceString(for: data, typename: __typename)
    }

    return nil
  }
}

/// The key for an object must be:
///   - Unique across the type
///     - No two different objects with the same "__typename" can have the same key.
///     - Keys do not need to be unique from keys for different types (objects with
///      different "__typename"s).
///   - Stable
///     - The key for an object may not ever change. If the cache recieves a new key, it will
///     treat the object as an entirely new object. There is no mechanisim for cache normalization
///     in which an object changes its key but maintains its identity.
///
/// Any format for keys will work, as long as they are stable and unique.
/// If multiple fields must be used to derive a unique key, we recommend joining the values for
/// the fields with a ":" delimiter. For example, if you need to join the title of a book and the
/// author name to use as a unique key, you could return "Iliad:Homer".
///
/// A reference to a record that does not have it's own unique cache key is based on a path from
/// another cache reference or a root object.
public protocol CacheKeyProvider {
  static var uniqueKeyGroupId: StaticString? { get }
  static func cacheKey(for data: JSONObject) -> String?
}

extension CacheKeyProvider {

  public static var uniqueKeyGroupId: StaticString? { nil }

  fileprivate static func cacheReferenceString(
    for data: JSONObject,
    typename: String
  ) -> String? {
    guard let key = cacheKey(for: data) else {
      return nil
    }

    return "\(uniqueKeyGroupId?.description ?? typename):\(key)"
  }

}

public protocol SchemaUnknownTypeCacheKeyProvider {
  static func cacheKeyProviderForUnknownType(
    withTypename: String,
    data: JSONObject
  ) -> CacheKeyProvider.Type?
}
