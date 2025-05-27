#if !COCOAPODS
import ApolloAPI
#endif

public protocol CacheInterceptor: Sendable {

  func readCacheData<Query: GraphQLQuery>(
    for query: Query
  ) async throws -> GraphQLResult<Query.Data>

  func writeCacheData<Operation: GraphQLOperation>(
    cacheRecords: RecordSet,
    for operation: Operation,
    with result: GraphQLResult<Operation.Data>
  ) async throws

}

public struct DefaultCacheInterceptor: CacheInterceptor {

  public let store: ApolloStore

  public init(store: ApolloStore) {
    self.store = store
  }

  public func readCacheData<Query: GraphQLQuery>(
    for query: Query
  ) async throws -> GraphQLResult<Query.Data> {    
    return try await store.load(query)
  }

  public func writeCacheData<Operation: GraphQLOperation>(
    cacheRecords: RecordSet,
    for operation: Operation,
    with result: GraphQLResult<Operation.Data>
  ) async throws {    
    try await store.publish(records: cacheRecords)
  }
  
}
