public protocol SchemaConfiguration {
  static func objectType(forTypename __typename: String) -> Object.Type?
}

extension SchemaConfiguration {
  public static func cacheKey(for data: JSONObject) -> CacheReference? {
    guard let __typename = data["__typename"] as? String,
          let keyString = cacheKeyString(for: data, withTypename: __typename) else {
      return nil
    }
    return CacheReference("\(__typename):\(keyString)")      
  }

  private static func cacheKeyString(
    for data: JSONObject,
    withTypename __typename: String
  ) -> String? {
    if let objectType = objectType(forTypename: __typename),
       let resolver = objectType as? CacheKeyProvider.Type {
      return resolver.cacheKey(for: data)
    }

    if let unknownTypeMapper = self as? SchemaUnknownTypeCacheKeyProvider.Type {
      return unknownTypeMapper.cacheKeyForUnknownType(withTypename: __typename, data: data)
    }

    return nil
  }
}

public protocol CacheKeyProvider: Object {
  static func cacheKey(for data: JSONObject) -> String?
}

public protocol SchemaUnknownTypeCacheKeyProvider {
  static func cacheKeyForUnknownType(withTypename: String, data: JSONObject) -> String?
}

