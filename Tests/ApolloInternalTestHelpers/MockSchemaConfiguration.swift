@testable import Apollo
@testable import ApolloAPI

extension Object {
  static let mock = Object(__typename: "Mock", __implementedInterfaces: [])
}

public class MockSchemaConfiguration: SchemaConfiguration {
  public init() { }

  private static let testObserver = TestObserver() { _ in
    stub_objectTypeForTypeName = nil
    stub_cacheKeyProviderForType = nil
  }

  #warning("TODO: rename these stubs")
  public static var stub_objectTypeForTypeName: ((String) -> Object?)? {
    didSet {
      if stub_objectTypeForTypeName != nil { testObserver.start() }
    }
  }

  public static var stub_cacheKeyProviderForType: ((Object) -> CacheKeyProvider?)? {
    didSet {
      if stub_cacheKeyProviderForType != nil { testObserver.start() }
    }
  }

}

public extension MockSchemaConfiguration {
  static func graphQLType(forTypename __typename: String) -> Object? {
    stub_objectTypeForTypeName?(__typename)
  }

  static func cacheKeyProvider(for type: Object) -> CacheKeyProvider? {
    stub_cacheKeyProviderForType?(type)
  }
}

public struct IDCacheKeyProvider: CacheKeyProvider {

  public static let shared = IDCacheKeyProvider()

  public func cacheKey(for data: JSONObject) -> String? {
    data["id"] as? String
  }
}

public struct MockCacheKeyProvider: CacheKeyProvider {
  let key: String

  public init(key: String) {
    self.key = key
  }

  public func cacheKey(for object: JSONObject) -> String? {
    key
  }
}

// MARK: - Custom Mock Schemas

public enum MockSchema1: SchemaConfiguration {
  public static func graphQLType(forTypename __typename: String) -> Object? {
    Object(__typename: "", __implementedInterfaces: [])
  }
}

public extension MockSchema1 {
  static func cacheKeyProvider(for type: Object) -> CacheKeyProvider? {
    MockCacheKeyProvider(key: "one")
  }
}

public enum MockSchema2: SchemaConfiguration {
  public static func graphQLType(forTypename __typename: String) -> Object? {
    Object(__typename: "", __implementedInterfaces: [])
  }
}

public extension MockSchema2 {
  static func cacheKeyProvider(for type: Object) -> CacheKeyProvider? {
    MockCacheKeyProvider(key: "two")
  }
}
