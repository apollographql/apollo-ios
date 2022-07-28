public protocol SchemaUnknownTypeCacheKeyProvider {
  func cacheKeyForUnknown(typename: String, data: JSONObject) -> String?
}

extension SchemaUnknownTypeCacheKeyProvider {
  func cacheReferenceString(data: JSONObject, typename: String) -> String? {
    guard let key = cacheKeyForUnknown(typename: typename, data: data) else {
      return nil
    }

    return "\(typename):\(key)"
  }
}
