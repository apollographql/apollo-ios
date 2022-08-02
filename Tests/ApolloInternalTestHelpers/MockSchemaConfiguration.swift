@testable import Apollo
@testable import ApolloAPI

extension Object {
  public static let mock = Object(typename: "Mock", implementedInterfaces: [])
}

public class MockSchemaConfiguration: SchemaConfiguration {
  public init() { }

  private static let testObserver = TestObserver() { _ in
    stub_graphQLTypeForTypeName = nil
    stub_cacheKeyInfoForType_Object = nil
  }

  public static var stub_graphQLTypeForTypeName: ((String) -> Object?)? {
    didSet {
      if stub_graphQLTypeForTypeName != nil { testObserver.start() }
    }
  }

  public static var stub_cacheKeyInfoForType_Object: ((Object, JSONObject) -> CacheKeyInfo?)? {
    didSet {
      if stub_cacheKeyInfoForType_Object != nil { testObserver.start() }
    }
  }

}

public extension MockSchemaConfiguration {
  static func graphQLType(forTypename __typename: String) -> Object? {
    stub_graphQLTypeForTypeName?(__typename) ??
    Object(typename: __typename, implementedInterfaces: [])
  }

  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    stub_cacheKeyInfoForType_Object?(type, object)
  }
}

// MARK - Mock Cache Key Providers

public protocol MockStaticCacheKeyProvider {
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo?
}

extension MockStaticCacheKeyProvider {
  public static var resolver: (Object, JSONObject) -> CacheKeyInfo? {
    cacheKeyInfo(for:object:)
  }
}

public struct IDCacheKeyProvider: MockStaticCacheKeyProvider {
  public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    try? .init(jsonValue: object["id"])
  }
}

public struct MockCacheKeyProvider {
  let key: String

  public init(key: String) {
    self.key = key
  }

  public func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    .init(key: key, uniqueKeyGroupId: nil)
  }
}

// MARK: - Custom Mock Schemas

public enum MockSchema1: SchemaConfiguration {
  public static func graphQLType(forTypename __typename: String) -> Object? {
    Object(typename: __typename, implementedInterfaces: [])
  }
}

public extension MockSchema1 {
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    CacheKeyInfo(key: "one")
  }
}

public enum MockSchema2: SchemaConfiguration {
  public static func graphQLType(forTypename __typename: String) -> Object? {
    Object(typename: __typename, implementedInterfaces: [])
  }
}

public extension MockSchema2 {
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    CacheKeyInfo(key: "two")
  }
}
