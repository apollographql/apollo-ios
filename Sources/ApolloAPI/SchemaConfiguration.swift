public protocol SchemaConfiguration {
  static func objectType(forTypename __typename: String) -> Object.Type?
  static var __unknownTypeCacheKeyProvider: SchemaUnknownTypeCacheKeyProvider? { get }
}

extension SchemaConfiguration {
  public static var __unknownTypeCacheKeyProvider: SchemaUnknownTypeCacheKeyProvider? { nil }

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
      return resolver.cacheReferenceString(data: data, typename: __typename)
    }

    if let resolver = __unknownTypeCacheKeyProvider {
      return resolver.cacheReferenceString(data: data, typename: __typename)
    }

    return nil
  }
}
