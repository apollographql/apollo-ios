@testable import Apollo
@testable import ApolloAPI

public class MockSchemaConfiguration: SchemaConfiguration, SchemaUnknownTypeCacheKeyProvider {

  private static let testObserver = TestObserver() { _ in
    stub_objectTypeForTypeName = nil
    stub_cacheKeyForUnknownType = nil
  }

  static public var stub_objectTypeForTypeName: ((String) -> Object.Type?)? {
    didSet {
      if stub_objectTypeForTypeName != nil { testObserver.start() }
    }
  }

  static public var stub_cacheKeyForUnknownType: ((String, JSONObject) -> String?)? {
    didSet {
      if stub_cacheKeyForUnknownType != nil { testObserver.start() }
    }
  }

  public static func objectType(forTypename __typename: String) -> Object.Type? {
    stub_objectTypeForTypeName?(__typename) ?? Object.self
  }

  public static func cacheKeyForUnknownType(withTypename: String, data: JSONObject) -> String? {
    stub_cacheKeyForUnknownType?(withTypename, data)
  }

}
