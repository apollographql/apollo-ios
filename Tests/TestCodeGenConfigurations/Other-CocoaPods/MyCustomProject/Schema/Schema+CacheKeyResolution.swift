import Apollo

extension Schema {
  public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    try? CacheKeyInfo(jsonValue: object["id"])
  }
}
