@testable import Apollo
@testable import ApolloAPI

public class MockSchemaConfiguration: SchemaConfiguration {
  public init() { }

  private static let testObserver = TestObserver() { _ in
    stub_objectTypeForTypeName = nil
    stub_cacheKeyProviderForUnknownType = nil
  }

  public static var stub_objectTypeForTypeName: ((String) -> Object.Type?)? {
    didSet {
      if stub_objectTypeForTypeName != nil { testObserver.start() }
    }
  }

  public static var stub_cacheKeyProviderForUnknownType: SchemaUnknownTypeCacheKeyProvider? {
    didSet {
      if stub_cacheKeyProviderForUnknownType != nil { testObserver.start() }
    }
  }

  public static func objectType(forTypename __typename: String) -> Object.Type? {
    stub_objectTypeForTypeName?(__typename) ?? Object.self
  }

  public static var __unknownTypeCacheKeyProvider: SchemaUnknownTypeCacheKeyProvider? {
    stub_cacheKeyProviderForUnknownType
  }
}

public struct UnknownTypeCacheKeyProvider: SchemaUnknownTypeCacheKeyProvider {
  public init() { }

  public func cacheKeyForUnknown(typename: String, data: JSONObject) -> String? {
    data["id"] as? String
  }
}
