public protocol SchemaConfiguration {
  static func objectType(forTypename __typename: String) -> Object?

  static func cacheKeyProvider(for type: Object) -> CacheKeyProvider?
}

extension SchemaConfiguration {

  public static func cacheKeyProvider(for type: Object) -> CacheKeyProvider? {
    nil
  }

  public static func cacheKey(
    for object: JSONObject
  ) -> CacheReference? {
    guard let typename = object["__typename"] as? String,
          let objectType = objectType(forTypename: typename),
          let provider = cacheKeyProvider(for: objectType),
          let keyString = provider.cacheReferenceString(for: object, typename: typename) else {
      return nil
    }

    return CacheReference(keyString)
  }
}
