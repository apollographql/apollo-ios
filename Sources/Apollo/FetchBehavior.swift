// MARK: Pre-defined Constants
extension FetchBehavior {
  /// Return data from the cache if available, else fetch results from the server.
  public static let CacheElseNetwork = FetchBehavior(
    cacheRead: .beforeNetworkFetch,
    networkFetch: .onCacheMiss
  )

  /// Return data from the cache if available, and always fetch results from the server.
  public static let CacheThenNetwork = FetchBehavior(
    cacheRead: .beforeNetworkFetch,
    networkFetch: .always
  )

  /// Attempt to fetch results from the server, if failed, return data from the cache if available.
  public static let NetworkElseCache = FetchBehavior(
    cacheRead: .onNetworkFailure,
    networkFetch: .always
  )

  /// Return data from the cache if available, do not attempt to fetch results from the server.
  public static let CacheOnly = FetchBehavior(
    cacheRead: .beforeNetworkFetch,
    networkFetch: .never
  )

  ///  Fetch results from the server, do not attempt to read data from the cache.
  public static let NetworkOnly = FetchBehavior(
    cacheRead: .never,
    networkFetch: .always
  )
}

// MARK: -

/// Describes the cache/networking behaviors that should be used for the execution of a GraphQL
/// request.
///
/// - Discussion: ``CachePolicy`` is designed to be the public facing API for determining these
///  behaviors. It is broken into multiple different types in order to provide the context needed to
///  dispatch to the correct ``ApolloClient`` function. ``ApolloClient`` then converts the
///  ``CachePolicy`` to a ``FetchBehavior`` which it provides to the ``NetworkTransport``. This
///  allows internal components (eg. ``RequestChain``) to operate on a single type for ease of use.
public struct FetchBehavior: Sendable, Hashable {
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

  public let cacheRead: CacheReadBehavior

  public let networkFetch: NetworkFetchBehavior

  fileprivate init(
    cacheRead: CacheReadBehavior,
    networkFetch: NetworkFetchBehavior
  ) {
    self.cacheRead = cacheRead
    self.networkFetch = networkFetch
  }

}
