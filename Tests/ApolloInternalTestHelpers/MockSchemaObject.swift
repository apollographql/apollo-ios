@testable import Apollo
@testable import ApolloAPI

public class MockSchemaObject: Object {
  private static let testObserver = TestObserver() { _ in
    stub_cacheKeyProvider = nil
  }

  public static var stub_cacheKeyProvider: CacheKeyProvider? {
    didSet {
      if stub_cacheKeyProvider != nil { testObserver.start() }
    }
  }
}

extension MockSchemaObject {
  public static var __cacheKeyProvider: CacheKeyProvider? { IDCacheKeyProvider() }
}

public struct IDCacheKeyProvider: CacheKeyProvider {
  public init() { }

  public func cacheKey(for data: JSONObject) -> String? {
    data["id"] as? String
  }
}
