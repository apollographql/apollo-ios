/// A set of cache policy for requests to an ``ApolloClient`` that specify whether results should be fetched from the
/// server or loaded from the local cache.
///
/// Cache Policy consists of multiple enums that can be used with different ``ApolloClient`` functions.
/// Different cache policy types can result in different return types for requests. Seperate enums are used to
/// determine what return type ``ApolloClient`` should provide.
public enum CachePolicy: Sendable, Hashable {

  public enum Query: Sendable, Hashable {
    public enum SingleResponse: Sendable, Hashable {
      /// Return data from the cache if available, else fetch results from the server.
      case cacheFirst
      /// Attempt to fetch results from the server, if failed, return data from the cache if available.
      case networkFirst
      ///  Fetch results from the server, do not attempt to read data from the cache.
      case networkOnly
    }

    public enum CacheOnly: Sendable, Hashable {
      /// Return data from the cache if available, do not attempt to fetch results from the server.
      case cacheOnly
    }

    public enum CacheAndNetwork: Sendable, Hashable {
      /// Return data from the cache if available, and always fetch results from the server.
      case cacheAndNetwork
    }
  }

  public enum Subscription: Sendable, Hashable {
    /// Return data from the cache if available, and always begin receiving subscription results from the server.
    case cacheThenNetwork
    /// Begin receiving subscription results from the server, do not attempt to read data from the cache.
    case networkOnly
  }

}

// MARK: - Fetch Behavior Conversion
extension CachePolicy.Query.SingleResponse {
  public func toFetchBehavior() -> FetchBehavior {
    switch self {
    case .cacheFirst:
      return FetchBehavior.CacheFirst

    case .networkFirst:
      return FetchBehavior.NetworkFirst

    case .networkOnly:
      return FetchBehavior.NetworkOnly
    }
  }
}

extension CachePolicy.Query.CacheOnly {
  public func toFetchBehavior() -> FetchBehavior {
    return FetchBehavior.CacheOnly
  }
}

extension CachePolicy.Query.CacheAndNetwork {
  public func toFetchBehavior() -> FetchBehavior {
    return FetchBehavior.CacheAndNetwork
  }
}

extension CachePolicy.Subscription {
  public func toFetchBehavior() -> FetchBehavior {
    switch self {
    case .cacheThenNetwork:
      return FetchBehavior.CacheAndNetwork

    case .networkOnly:
      return FetchBehavior.NetworkOnly
    }
  }
}
