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
       let resolver = objectType as? CacheKeyProvider.Type {
      return resolver.cacheReferenceString(data: data, typename: __typename)
    }

    if let resolver = self as? SchemaUnknownTypeCacheKeyProvider.Type {
      return resolver.cacheReferenceString(data: data, typename: __typename)
    }

    return nil
  }
}

public protocol CacheKeyProvider {
  static var uniqueKeyGroupId: StaticString? { get }
  static func cacheKey(for data: JSONObject) -> String?
}

extension CacheKeyProvider {

  public static var uniqueKeyGroupId: StaticString? { nil }

  fileprivate static func cacheReferenceString(key: String, typename: String) -> String? {
    return "\(uniqueKeyGroupId?.description ?? typename):\(key)"
  }

  fileprivate static func cacheReferenceString(data: JSONObject, typename: String) -> String? {
    guard let key = cacheKey(for: data) else {
      return nil
    }

    return cacheReferenceString(key: key, typename: typename)
  }

}

public protocol SchemaUnknownTypeCacheKeyProvider: CacheKeyProvider {
  static func cacheKeyForUnknown(typename: String, data: JSONObject) -> String?
}

extension SchemaUnknownTypeCacheKeyProvider {
  public static func cacheKey(for data: JSONObject) -> String? { nil }

  fileprivate static func cacheReferenceString(data: JSONObject, typename: String) -> String? {
    guard let key = cacheKeyForUnknown(typename: typename, data: data) else {
      return nil
    }

    return cacheReferenceString(key: key, typename: typename)
  }
}
