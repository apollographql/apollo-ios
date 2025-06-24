#if !COCOAPODS
  import ApolloAPI
#endif

public protocol CacheInterceptor: Sendable {

  func readCacheData<Request: GraphQLRequest>(
    from store: ApolloStore,
    request: Request
  ) async throws -> GraphQLResult<Request.Operation.Data> where Request.Operation: GraphQLQuery

  func writeCacheData<Request: GraphQLRequest>(
    to store: ApolloStore,
    request: Request,
    response: GraphQLResponse<Request.Operation>,
  ) async throws

}

public struct DefaultCacheInterceptor: CacheInterceptor {

  public init() {}

  public func readCacheData<Request: GraphQLRequest>(
    from store: ApolloStore,
    request: Request
  ) async throws -> GraphQLResult<Request.Operation.Data> where Request.Operation: GraphQLQuery {
    return try await store.load(request.operation)
  }

  public func writeCacheData<Request: GraphQLRequest>(
    to store: ApolloStore,
    request: Request,
    response: GraphQLResponse<Request.Operation>,
  ) async throws {
    if let records = response.cacheRecords {
      try await store.publish(records: records)
    }
  }

}
