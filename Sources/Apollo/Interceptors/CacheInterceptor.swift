import ApolloAPI

/// A protocol for an interceptor in a ``RequestChain`` that handles cache reads and writes.
///
/// For most use cases, the ``DefaultCacheInterceptor`` will be sufficient to perform direct cache reads and writes. If
/// you require custom logic for manipulating cache data, that cannot be achieved by using the
/// [`@typePolicy` and `@fieldPolicy` directives](https://www.apollographql.com/docs/ios/caching/cache-key-resolution)
/// or [programmatic cache key configuration](https://www.apollographql.com/docs/ios/caching/programmatic-cache-keys),
/// you may need to implement a custom ``CacheInterceptor``.
public protocol CacheInterceptor: Sendable {

  /// Reads cache data from the given ``ApolloStore`` for the request.
  ///
  /// This function will be called after the pre-flight steps of the ``GraphQLInterceptor``s in the ``RequestChain``
  /// are completed if the `request`'s ``GraphQLRequest/fetchBehavior`` indicates that a pre-fetch cache read should be
  /// attempted.
  ///
  /// Additionally, this function will be called after a failed network fetch if the `request`'s
  /// ``GraphQLRequest/fetchBehavior`` indicates that a cache read should be attempted on a network failure.
  ///
  /// - Parameters:
  ///   - store: The ``ApolloStore`` to read cache data from
  ///   - request: The ``GraphQLRequest`` to read cache data for
  /// - Returns: A ``GraphQLResponse`` read from the cache if the data exists. Should return `nil` on a cache miss.
  func readCacheData<Request: GraphQLRequest>(
    from store: ApolloStore,
    request: Request
  ) async throws -> GraphQLResponse<Request.Operation>?
  
  /// Writes response data for a request to the given ``ApolloStore``.
  ///
  /// The `response`'s ``ParsedResult/cacheRecords`` field contains the record set that should be written to the cache.
  ///
  /// This function will be called after the post-flight response data has been parsed and successfully processed
  /// through all of the ``RequestChain``'s ``GraphQLInterceptor``s.
  ///
  /// - Parameters:
  ///   - store: The ``ApolloStore`` to write cache data to
  ///   - request: The ``GraphQLRequest`` used to fetch the data in the `response`
  ///   - response: The parsed response data for the `request`
  func writeCacheData<Request: GraphQLRequest>(
    to store: ApolloStore,
    request: Request,
    response: ParsedResult<Request.Operation>
  ) async throws

}

/// A default implementation of a ``CacheInterceptor`` which performs direct cache reads and writes to the given
/// ``ApolloStore``.
public struct DefaultCacheInterceptor: CacheInterceptor {

  public init() {}

  public func readCacheData<Request: GraphQLRequest>(
    from store: ApolloStore,
    request: Request
  ) async throws -> GraphQLResponse<Request.Operation>? {
    return try await store.load(request.operation)
  }

  public func writeCacheData<Request: GraphQLRequest>(
    to store: ApolloStore,
    request: Request,
    response: ParsedResult<Request.Operation>
  ) async throws {
    if let records = response.cacheRecords {
      try await store.publish(records: records)
    }
  }

}
