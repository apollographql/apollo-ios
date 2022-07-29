public protocol CacheKeyProvider {
  var uniqueKeyGroupId: String? { get }
  func cacheKey(for object: JSONObject) -> String?
}

extension CacheKeyProvider {
  public var uniqueKeyGroupId: String? { nil }

  func cacheReferenceString(for object: JSONObject, typename: String) -> String? {
    guard let key = cacheKey(for: object) else {
      return nil
    }

    return "\(uniqueKeyGroupId?.description ?? typename):\(key)"
  }
}
