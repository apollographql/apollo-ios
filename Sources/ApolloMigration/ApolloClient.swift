import Foundation
import Dispatch
#if !COCOAPODS
import ApolloMigrationAPI
#endif

/// A cache policy that specifies whether results should be fetched from the server or loaded from the local cache.
public enum CachePolicy: Hashable {
  /// Return data from the cache if available, else fetch results from the server.
  case returnCacheDataElseFetch
  ///  Always fetch results from the server.
  case fetchIgnoringCacheData
  ///  Always fetch results from the server, and don't store these in the cache.
  case fetchIgnoringCacheCompletely
  /// Return data from the cache if available, else return an error.
  case returnCacheDataDontFetch
  /// Return data from the cache if available, and always fetch results from the server.
  case returnCacheDataAndFetch
  
  /// The current default cache policy.
  public static var `default`: CachePolicy = .returnCacheDataElseFetch
}

/// A handler for operation results.
///
/// - Parameters:
///   - result: The result of a performed operation. Will have a `GraphQLResult` with any parsed data and any GraphQL errors on `success`, and an `Error` on `failure`.
public typealias GraphQLResultHandler<Data: RootSelectionSet> = (Result<GraphQLResult<Data>, any Error>) -> Void

/// The `ApolloClient` class implements the core API for Apollo by conforming to `ApolloClientProtocol`.
public class ApolloClient {

  let networkTransport: any NetworkTransport

  public let store: ApolloStore

  public enum ApolloClientError: Error, LocalizedError, Hashable {
    case noUploadTransport

    public var errorDescription: String? {
      switch self {
      case .noUploadTransport:
        return "Attempting to upload using a transport which does not support uploads. This is a developer error."
      }
    }
  }

  /// Creates a client with the specified network transport and store.
  ///
  /// - Parameters:
  ///   - networkTransport: A network transport used to send operations to a server.
  ///   - store: A store used as a local cache. Note that if the `NetworkTransport` or any of its dependencies takes a store, you should make sure the same store is passed here so that it can be cleared properly.
  public init(networkTransport: any NetworkTransport, store: ApolloStore) {
    self.networkTransport = networkTransport
    self.store = store
  }

  /// Creates a client with a `RequestChainNetworkTransport` connecting to the specified URL.
  ///
  /// - Parameter url: The URL of a GraphQL server to connect to.
  public convenience init(url: URL) {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = DefaultInterceptorProvider(store: store)
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: url)
    
    self.init(networkTransport: transport, store: store)
  }
}

// MARK: - ApolloClientProtocol conformance

extension ApolloClient: ApolloClientProtocol {

  public func clearCache(callbackQueue: DispatchQueue = .main,
                         completion: ((Result<Void, any Error>) -> Void)? = nil) {
    self.store.clearCache(callbackQueue: callbackQueue, completion: completion)
  }
  
  @discardableResult public func fetch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy = .default,
    contextIdentifier: UUID? = nil,
    context: (any RequestContext)? = nil,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Query.Data>? = nil
  ) -> (any Cancellable) {
    return self.networkTransport.send(operation: query,
                                      cachePolicy: cachePolicy,
                                      contextIdentifier: contextIdentifier,
                                      context: context,
                                      callbackQueue: queue) { result in
      resultHandler?(result)
    }
  }

  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - refetchOnFailedUpdates: Should the watcher perform a network fetch when it's watched
  ///     objects have changed, but reloading them from the cache fails. Should default to `true`.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - callbackQueue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  ///   - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy = .default,
    refetchOnFailedUpdates: Bool = true,
    context: (any RequestContext)? = nil,
    callbackQueue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Query.Data>
  ) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self,
                                      query: query,
                                      refetchOnFailedUpdates: refetchOnFailedUpdates,
                                      context: context,
                                      callbackQueue: callbackQueue,
                                      resultHandler: resultHandler)
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }

  @discardableResult
  public func perform<Mutation: GraphQLMutation>(
    mutation: Mutation,
    publishResultToStore: Bool = true,
    contextIdentifier: UUID? = nil,
    context: (any RequestContext)? = nil,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Mutation.Data>? = nil
  ) -> (any Cancellable) {
    return self.networkTransport.send(
      operation: mutation,
      cachePolicy: publishResultToStore ? .default : .fetchIgnoringCacheCompletely,
      contextIdentifier: contextIdentifier,
      context: context,
      callbackQueue: queue,
      completionHandler: { result in
        resultHandler?(result)
      }
    )
  }

  @discardableResult
  public func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    context: (any RequestContext)? = nil,
    queue: DispatchQueue = .main,
    resultHandler: GraphQLResultHandler<Operation.Data>? = nil
  ) -> (any Cancellable) {
    guard let uploadingTransport = self.networkTransport as? (any UploadingNetworkTransport) else {
      assertionFailure("Trying to upload without an uploading transport. Please make sure your network transport conforms to `UploadingNetworkTransport`.")
      queue.async {
        resultHandler?(.failure(ApolloClientError.noUploadTransport))
      }
      return EmptyCancellable()
    }

    return uploadingTransport.upload(operation: operation,
                                     files: files,
                                     context: context,
                                     callbackQueue: queue) { result in
      resultHandler?(result)
    }
  }

  public func subscribe<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    context: (any RequestContext)? = nil,
    queue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Subscription.Data>
  ) -> any Cancellable {
    return self.networkTransport.send(operation: subscription,
                                      cachePolicy: .default,
                                      contextIdentifier: nil,
                                      context: context,
                                      callbackQueue: queue,
                                      completionHandler: resultHandler)
  }
}

// MARK: - Deprecations

extension ApolloClient {

  @_disfavoredOverload
  @available(*, deprecated,
              renamed: "watch(query:cachePolicy:refetchOnFailedUpdates:context:callbackQueue:resultHandler:)")
  public func watch<Query: GraphQLQuery>(
    query: Query,
    cachePolicy: CachePolicy = .default,
    context: (any RequestContext)? = nil,
    callbackQueue: DispatchQueue = .main,
    resultHandler: @escaping GraphQLResultHandler<Query.Data>
  ) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self,
                                      query: query,
                                      context: context,
                                      callbackQueue: callbackQueue,
                                      resultHandler: resultHandler)
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }

}
