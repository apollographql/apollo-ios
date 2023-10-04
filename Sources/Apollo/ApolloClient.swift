import Foundation
import Dispatch
#if !COCOAPODS
import ApolloAPI
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
public typealias GraphQLResultHandler<Data: RootSelectionSet> = (Result<GraphQLResult<Data>, Error>) -> Void

/// The `ApolloClient` class implements the core API for Apollo by conforming to `ApolloClientProtocol`.
public class ApolloClient {

  let networkTransport: NetworkTransport

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
  public init(networkTransport: NetworkTransport, store: ApolloStore) {
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
                         completion: ((Result<Void, Error>) -> Void)? = nil) {
    self.store.clearCache(callbackQueue: callbackQueue, completion: completion)
  }
  
  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query,
                                                            cachePolicy: CachePolicy = .default,
                                                            contextIdentifier: UUID? = nil,
                                                            context: RequestContext? = nil,
                                                            queue: DispatchQueue = .main,
                                                            resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
    return self.networkTransport.send(operation: query,
                                      cachePolicy: cachePolicy,
                                      contextIdentifier: contextIdentifier,
                                      context: context,
                                      callbackQueue: queue) { result in
      resultHandler?(result)
    }
  }

  public func watch<Query: GraphQLQuery>(query: Query,
                                         cachePolicy: CachePolicy = .default,
                                         context: RequestContext? = nil,
                                         callbackQueue: DispatchQueue = .main,
                                         resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self,
                                      query: query,
                                      context: context,
                                      callbackQueue: callbackQueue,
                                      resultHandler: resultHandler)
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }

  @discardableResult
  public func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                                 publishResultToStore: Bool = true,
                                                 context: RequestContext? = nil,
                                                 queue: DispatchQueue = .main,
                                                 resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable {
    return self.networkTransport.send(
      operation: mutation,
      cachePolicy: publishResultToStore ? .default : .fetchIgnoringCacheCompletely,
      contextIdentifier: nil,
      context: context,
      callbackQueue: queue,
      completionHandler: { result in
        resultHandler?(result)
      }
    )
  }

  @discardableResult
  public func upload<Operation: GraphQLOperation>(operation: Operation,
                                                  files: [GraphQLFile],
                                                  context: RequestContext? = nil,
                                                  queue: DispatchQueue = .main,
                                                  resultHandler: GraphQLResultHandler<Operation.Data>? = nil) -> Cancellable {
    guard let uploadingTransport = self.networkTransport as? UploadingNetworkTransport else {
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
  
  public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                           context: RequestContext? = nil,
                                                           queue: DispatchQueue = .main,
                                                           resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable {
    return self.networkTransport.send(operation: subscription,
                                      cachePolicy: .default,
                                      contextIdentifier: nil,
                                      context: context,
                                      callbackQueue: queue,
                                      completionHandler: resultHandler)
  }
}


