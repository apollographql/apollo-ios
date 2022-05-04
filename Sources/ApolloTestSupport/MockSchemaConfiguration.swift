@testable import Apollo
@testable import ApolloAPI

public class MockSchemaConfiguration: SchemaConfiguration, SchemaUnknownTypeCacheKeyProvider {

  private static let testObserver = TestObserver() { _ in
    stub_objectTypeForTypeName = nil
    stub_cacheKeyProviderForUnknownType = nil
  }

  static public var stub_objectTypeForTypeName: ((String) -> Object.Type?)? {
    didSet {
      if stub_objectTypeForTypeName != nil { testObserver.start() }
    }
  }

  static public var stub_cacheKeyProviderForUnknownType:
  ((String, JSONObject) -> CacheKeyProvider.Type?)?
  {
    didSet {
      if stub_cacheKeyProviderForUnknownType != nil { testObserver.start() }
    }
  }

  public static func objectType(forTypename __typename: String) -> Object.Type? {
    stub_objectTypeForTypeName?(__typename) ?? Object.self
  }

  public static func cacheKeyProviderForUnknownType(
    withTypename: String,
    data: JSONObject
  ) -> CacheKeyProvider.Type? {
    stub_cacheKeyProviderForUnknownType?(withTypename, data)
  }

}

public enum IDCacheKeyProvider: CacheKeyProvider {
  public static func cacheKey(for data: JSONObject) -> String? {
    data["id"] as? String
  }
}
