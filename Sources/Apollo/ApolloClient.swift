import Foundation
import Dispatch

/// A cache policy that specifies whether results should be fetched from the server or loaded from the local cache.
public enum CachePolicy {
  /// Return data from the cache if available, else fetch results from the server.
  case returnCacheDataElseFetch
  ///  Always fetch results from the server.
  case fetchIgnoringCacheData
  ///  Always fetch results from the server, and don't store these in the cache.
  case fetchIgnoringCacheCompletely
  /// Return data from the cache if available, else return nil.
  case returnCacheDataDontFetch
  /// Return data from the cache if available, and always fetch results from the server.
  case returnCacheDataAndFetch
  
  public static var `default`: CachePolicy {
    .returnCacheDataElseFetch
  }
}

/// A handler for operation results.
///
/// - Parameters:
///   - result: The result of a performed operation. Will have a `GraphQLResult` with any parsed data and any GraphQL errors on `success`, and an `Error` on `failure`.
public typealias GraphQLResultHandler<Data> = (Result<GraphQLResult<Data>, Error>) -> Void

/// The `ApolloClient` class implements the core API for Apollo by conforming to `ApolloClientProtocol`.
public class ApolloClient {

  let networkTransport: NetworkTransport

  public let store: ApolloStore // <- conformance to ApolloClientProtocol

  private let queue: DispatchQueue
  private let operationQueue: OperationQueue

  public enum ApolloClientError: Error, LocalizedError {
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
  ///   - store: A store used as a local cache. Should default to an empty store backed by an in-memory cache.
  public init(networkTransport: NetworkTransport, store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache())) {
    self.networkTransport = networkTransport
    self.store = store

    queue = DispatchQueue(label: "com.apollographql.ApolloClient")
    operationQueue = OperationQueue()
    operationQueue.underlyingQueue = queue
  }

  /// Creates a client with an HTTP network transport connecting to the specified URL.
  ///
  /// - Parameter url: The URL of a GraphQL server to connect to.
  public convenience init(url: URL) {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let provider = LegacyInterceptorProvider(store: store)
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: url)
    
    self.init(networkTransport: transport, store: store)
  }

  private func handleOperationResult<Data: GraphQLSelectionSet>(shouldPublishResultToStore: Bool,
                                                                context: UnsafeMutableRawPointer?,
                                                                _ result: Result<GraphQLResponse<Data>, Error>,
                                                                resultHandler: @escaping GraphQLResultHandler<Data>) {
    switch result {
    case .failure(let error):
      resultHandler(.failure(error))
    case .success(let response):
      // If there is no need to publish the result to the store, we can use a fast path.
      if !shouldPublishResultToStore {
        do {
          let result = try response.parseResultFast()
          resultHandler(.success(result))
        } catch {
          resultHandler(.failure(error))
        }
        return
      }

      firstly {
        try response.parseResult(cacheKeyForObject: self.cacheKeyForObject)
        }.andThen { [weak self] (result, records) in
          guard let self = self else {
            return
          }
          if let records = records {
            self.store.publish(records: records, context: context).catch { error in
              preconditionFailure(String(describing: error))
            }
          }
          resultHandler(.success(result))
        }.catch { error in
          resultHandler(.failure(error))
      }
    }
  }
}

// MARK: - ApolloClientProtocol conformance

extension ApolloClient: ApolloClientProtocol {

  public var cacheKeyForObject: CacheKeyForObject? {
    get {
      return self.store.cacheKeyForObject
    }

    set {
      self.store.cacheKeyForObject = newValue
    }
  }

  public func clearCache(callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Error>) -> Void)? = nil) {
    self.store.clearCache(completion: completion)
  }
  
  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query,
                                                                     cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                                                     context: UnsafeMutableRawPointer? = nil,
                                                                     queue: DispatchQueue = DispatchQueue.main,
                                                                     resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
    return self.networkTransport.send(operation: query,
                                      cachePolicy: cachePolicy,
                                      completionHandler: wrapResultHandler(resultHandler, queue: queue))
  }

  public func watch<Query: GraphQLQuery>(query: Query,
                                         cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                         queue: DispatchQueue = .main,
                                         resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self,
                                      query: query,
                                      resultHandler: wrapResultHandler(resultHandler, queue: queue))
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }

  @discardableResult
  public func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                                          queue: DispatchQueue = .main,
                                                          resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable {
    return self.networkTransport.send(operation: mutation, cachePolicy: .default) { result in
      resultHandler?(result)
    }
  }

  @discardableResult
  public func upload<Operation: GraphQLOperation>(operation: Operation,
                                                  files: [GraphQLFile],
                                                  queue: DispatchQueue = .main,
                                                  resultHandler: GraphQLResultHandler<Operation.Data>? = nil) -> Cancellable {
    let wrappedHandler = wrapResultHandler(resultHandler, queue: queue)
    guard let uploadingTransport = self.networkTransport as? UploadingNetworkTransport else {
      assertionFailure("Trying to upload without an uploading transport. Please make sure your network transport conforms to `UploadingNetworkTransport`.")
      wrappedHandler(.failure(ApolloClientError.noUploadTransport))
      return EmptyCancellable()
    }

    return uploadingTransport.upload(operation: operation, files: files) { result in
      resultHandler?(result)
    }
  }
  

  @discardableResult
  public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                           queue: DispatchQueue = .main,
                                                           resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable {
    return self.networkTransport.send(operation: subscription,
                                      cachePolicy: .default,
                                      completionHandler: wrapResultHandler(resultHandler, queue: queue))
  }
}

private func wrapResultHandler<Data>(_ resultHandler: GraphQLResultHandler<Data>?, queue handlerQueue: DispatchQueue) -> GraphQLResultHandler<Data> {
  guard let resultHandler = resultHandler else {
    return { _ in }
  }

  return { result in
    handlerQueue.async {
      resultHandler(result)
    }
  }
}
