public struct FetchBehavior: Sendable, Hashable {

  // Pre-defined Constants

  public static let CacheElseNetwork = FetchBehavior(
    cacheRead: .beforeNetworkFetch,
    networkFetch: .onCacheMiss
  )

  public static let CacheThenNetwork = FetchBehavior(
    cacheRead: .beforeNetworkFetch,
    networkFetch: .always
  )

  public static let NetworkElseCache = FetchBehavior(
    cacheRead: .onNetworkFailure,
    networkFetch: .always
  )

  public static let CacheOnly = FetchBehavior(
    cacheRead: .beforeNetworkFetch,
    networkFetch: .never
  )

  public static let NetworkOnly = FetchBehavior(
    cacheRead: .never,
    networkFetch: .always
  )

  public var cacheRead: CacheReadBehavior

  public var networkFetch: NetworkFetchBehavior

  public enum CacheReadBehavior: Sendable {
    case never
    case beforeNetworkFetch
    case onNetworkFailure
  }

  public enum NetworkFetchBehavior: Sendable {
    case never
    case always
    case onCacheMiss
  }

  public init(
    cacheRead: CacheReadBehavior,
    networkFetch: NetworkFetchBehavior
  ) {
    self.cacheRead = cacheRead
    self.networkFetch = networkFetch
  }

}
