public protocol CacheKeyProvider {
  var uniqueKeyGroupId: StaticString? { get }
  func cacheKey(for data: JSONObject) -> String?
}

extension CacheKeyProvider {
  public var uniqueKeyGroupId: StaticString? { nil }

  func cacheReferenceString(data: JSONObject, typename: String) -> String? {
    guard let key = cacheKey(for: data) else {
      return nil
    }

    return "\(uniqueKeyGroupId?.description ?? typename):\(key)"
  }
}
