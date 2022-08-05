public protocol SchemaConfiguration {
  static func objectType(forTypename typename: String) -> Object?
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo?
}

extension SchemaConfiguration {

  @inlinable public static func cacheKeyInfo(
    for type: Object,
    object: JSONObject
  ) -> CacheKeyInfo? {
    nil
  }

  @inlinable public static func graphQLType(for object: JSONObject) -> Object? {
    guard let typename = object["__typename"] as? String else {
      return nil
    }
    return objectType(forTypename: typename)
  }

  @inlinable public static func cacheKey(for object: JSONObject) -> CacheReference? {
    guard let type = graphQLType(for: object),
          let info = cacheKeyInfo(for: type, object: object) else {
      return nil
    }
    return CacheReference("\(info.uniqueKeyGroupId ?? type.typename):\(info.key)")
  }
}

public struct CacheKeyInfo {
  public let key: String
  public let uniqueKeyGroupId: String?

  @inlinable public init(jsonValue: JSONValue?, uniqueKeyGroupId: String? = nil) throws {
    guard let jsonValue = jsonValue else {
      throw JSONDecodingError.missingValue
    }

    self.init(key: try String(jsonValue: jsonValue), uniqueKeyGroupId: uniqueKeyGroupId)
  }

  @inlinable public init(key: String, uniqueKeyGroupId: String? = nil) {
    self.key = key
    self.uniqueKeyGroupId = uniqueKeyGroupId
  }
}
