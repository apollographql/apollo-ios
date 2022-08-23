@testable import Apollo
@testable import ApolloAPI

extension Object {
  public static let mock = Object(typename: "Mock", implementedInterfaces: [])
}

public class MockSchemaMetadata: SchemaMetadata {
  public init() { }

  public static var _configuration: SchemaConfiguration.Type = SchemaConfiguration.self
  public static var configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  private static let testObserver = TestObserver() { _ in
    stub_objectTypeForTypeName = nil
    stub_cacheKeyInfoForType_Object = nil
  }

  public static var stub_objectTypeForTypeName: ((String) -> Object?)? {
    didSet {
      if stub_objectTypeForTypeName != nil { testObserver.start() }
    }
  }

  public static var stub_cacheKeyInfoForType_Object: ((Object, JSONObject) -> CacheKeyInfo?)? {
    get {
      _configuration.stub_cacheKeyInfoForType_Object
    }
    set {
      _configuration.stub_cacheKeyInfoForType_Object = newValue
      if newValue != nil { testObserver.start() }
    }
  }

  public static func objectType(forTypename __typename: String) -> Object? {
    if let stub = stub_objectTypeForTypeName {
      return stub(__typename)
    }

    return Object(typename: __typename, implementedInterfaces: [])
  }

  public class SchemaConfiguration: ApolloAPI.SchemaConfiguration {
    static var stub_cacheKeyInfoForType_Object: ((Object, JSONObject) -> CacheKeyInfo?)?

    public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
      stub_cacheKeyInfoForType_Object?(type, object)
    }
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

public enum MockSchema1: SchemaMetadata {
  public static var configuration: SchemaConfiguration.Type = MockSchema1Configuration.self

  public static func objectType(forTypename __typename: String) -> Object? {
    Object(typename: __typename, implementedInterfaces: [])
  }
}

public enum MockSchema1Configuration: SchemaConfiguration {
  public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    CacheKeyInfo(key: "one")
  }
}

public enum MockSchema2: SchemaMetadata {
  public static var configuration: SchemaConfiguration.Type = MockSchema2Configuration.self

  public static func objectType(forTypename __typename: String) -> Object? {
    Object(typename: __typename, implementedInterfaces: [])
  }
}

public enum MockSchema2Configuration: SchemaConfiguration {
  public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    CacheKeyInfo(key: "two")
  }
}
