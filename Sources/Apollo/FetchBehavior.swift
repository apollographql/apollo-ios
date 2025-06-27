public struct FetchBehavior: Sendable, Hashable {

  public let cacheRead: CacheReadBehavior

  public let networkFetch: NetworkFetchBehavior

  public init(
    cacheRead: CacheReadBehavior,
    networkFetch: NetworkFetchBehavior
  ) {
    self.cacheRead = cacheRead
    self.networkFetch = networkFetch
  }

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
}
