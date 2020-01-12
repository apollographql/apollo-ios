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
}

/// Metadata about the returned result.
public struct GraphQLResultContext {
  /// The date when the result was received.
  /// When reading from cache, Apollo can merge several records of different age. In such case
  /// this value is the date when the oldest record was received.
  public let resultAge: Date

  init(resultAge: Date = Date()) {
    self.resultAge = resultAge
  }
}

/// A handler for operation results.
///
/// - Parameters:
///   - result: The result of a performed operation. Will have a `GraphQLResult` with any parsed data and any GraphQL errors on `success`, and an `Error` on `failure`.
public typealias GraphQLResultHandler<Data> = (Result<GraphQLResult<Data>, Error>) -> Void

/// A handler for operation results and their metadata.
///
/// - Parameters:
///   - result: The result of a performed operation. On `success` it will have a `GraphQLResult` with any parsed data and any GraphQL errors and a `GraphQLResultContext` that holds contextual information, and an `Error` on `failure`.
public typealias GraphQLResultWithContextHandler<Data> = (Result<(GraphQLResult<Data>, GraphQLResultContext), Error>) -> Void

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
    self.init(networkTransport: HTTPNetworkTransport(url: url))
  }
  
  fileprivate func send<Operation: GraphQLOperation>(operation: Operation,
                                                     shouldPublishResultToStore: Bool,
                                                     context: UnsafeMutableRawPointer?,
                                                     resultHandler: @escaping GraphQLResultWithContextHandler<Operation.Data>) -> Cancellable {
    return networkTransport.send(operation: operation) { [weak self] (result: Result<GraphQLResponse<Operation>, Error>) -> Void in
      guard let self = self else {
        return
      }
      let resultWithContext: Result<(GraphQLResponse<Operation>, GraphQLResultContext), Error> = {
        switch result {
        case .success(let data):
          return .success((data, GraphQLResultContext()))
        case .failure(let error):
          return .failure(error)
        }
      }()
      self.handleOperationResult(shouldPublishResultToStore: shouldPublishResultToStore,
                                 context: context,
                                 resultWithContext,
                                 resultHandler: resultHandler)
    }
  }
  
  private func handleOperationResult<Operation>(shouldPublishResultToStore: Bool,
                                                context: UnsafeMutableRawPointer?,
                                                _ result: Result<(GraphQLResponse<Operation>, GraphQLResultContext), Error>,
                                                resultHandler: @escaping GraphQLResultWithContextHandler<Operation.Data>) {
    switch result {
    case .failure(let error):
      resultHandler(.failure(error))
    case .success(let (response, responseContext)):
      // If there is no need to publish the result to the store, we can use a fast path.
      if !shouldPublishResultToStore {
        do {
          let result = try response.parseResultFast()
          resultHandler(.success((result, responseContext)))
        } catch {
          resultHandler(.failure(error))
        }
        return
      }
      
      firstly {
        try response.parseResult(cacheKeyForObject: self.cacheKeyForObject)
        }.andThen { [weak self] (result, records, resultContext) in
          guard let self = self else {
            return
          }
          if let records = records {
            self.store.publish(records: records, context: context).catch { error in
              preconditionFailure(String(describing: error))
            }
          }
          resultHandler(.success((result, responseContext)))
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
  
  @discardableResult public func fetchWithContext<Query: GraphQLQuery>(query: Query,
                                                            cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                                            context: UnsafeMutableRawPointer? = nil,
                                                            queue: DispatchQueue = DispatchQueue.main,
                                                            resultHandler: GraphQLResultWithContextHandler<Query.Data>? = nil) -> Cancellable {
    let resultHandler = wrapResultHandler(resultHandler, queue: queue)
    
    // If we don't have to go through the cache, there is no need to create an operation
    // and we can return a network task directly
    if cachePolicy == .fetchIgnoringCacheData || cachePolicy == .fetchIgnoringCacheCompletely {
      return self.send(operation: query, shouldPublishResultToStore: cachePolicy != .fetchIgnoringCacheCompletely, context: context, resultHandler: resultHandler)
    } else {
      let operation = FetchQueryOperation(client: self, query: query, cachePolicy: cachePolicy, context: context, resultHandler: resultHandler)
      self.operationQueue.addOperation(operation)
      return operation
    }
  }
  
  public func watchWithContext<Query: GraphQLQuery>(query: Query,
                                         cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                         queue: DispatchQueue = .main,
                                         resultHandler: @escaping GraphQLResultWithContextHandler<Query.Data>) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self,
                                      query: query,
                                      resultHandler: wrapResultHandler(resultHandler, queue: queue))
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }
  
  @discardableResult
  public func performWithContext<Mutation: GraphQLMutation>(mutation: Mutation,
                                                 context: UnsafeMutableRawPointer? = nil,
                                                 queue: DispatchQueue = DispatchQueue.main,
                                                 resultHandler: GraphQLResultWithContextHandler<Mutation.Data>? = nil) -> Cancellable {
    return self.send(operation: mutation,
                     shouldPublishResultToStore: true,
                     context: context,
                     resultHandler: wrapResultHandler(resultHandler, queue: queue))
  }
  
  @discardableResult
  public func uploadWithContext<Operation: GraphQLOperation>(operation: Operation,
                                                  context: UnsafeMutableRawPointer? = nil,
                                                  files: [GraphQLFile],
                                                  queue: DispatchQueue = .main,
                                                  resultHandler: GraphQLResultWithContextHandler<Operation.Data>? = nil) -> Cancellable {
    let wrappedHandler = wrapResultHandler(resultHandler, queue: queue)
    guard let uploadingTransport = self.networkTransport as? UploadingNetworkTransport else {
      assertionFailure("Trying to upload without an uploading transport. Please make sure your network transport conforms to `UploadingNetworkTransport`.")
      wrappedHandler(.failure(ApolloClientError.noUploadTransport))
      return EmptyCancellable()
    }
    
    return uploadingTransport.upload(operation: operation, files: files) { [weak self] result in
      guard let self = self else {
        return
      }
      let resultWithContext: Result<(GraphQLResponse<Operation>, GraphQLResultContext), Error> = {
        switch result {
        case .success(let data):
          return .success((data, GraphQLResultContext()))
        case .failure(let error):
          return .failure(error)
        }
      }()
      self.handleOperationResult(shouldPublishResultToStore: true,
                                 context: context, resultWithContext,
                                 resultHandler: wrappedHandler)
    }
  }
  
  @discardableResult
  public func subscribeWithContext<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                           queue: DispatchQueue = .main,
                                                           resultHandler: @escaping GraphQLResultWithContextHandler<Subscription.Data>) -> Cancellable {
    return self.send(operation: subscription,
                     shouldPublishResultToStore: true,
                     context: nil,
                     resultHandler: wrapResultHandler(resultHandler, queue: queue))
  }
}

private func wrapResultHandler<Data>(_ resultHandler: GraphQLResultWithContextHandler<Data>?, queue handlerQueue: DispatchQueue) -> GraphQLResultWithContextHandler<Data> {
  guard let resultHandler = resultHandler else {
    return { _ in }
  }
  
  return { result in
    handlerQueue.async {
      resultHandler(result)
    }
  }
}

private final class FetchQueryOperation<Query: GraphQLQuery>: AsynchronousOperation, Cancellable {
  weak var client: ApolloClient?
  let query: Query
  let cachePolicy: CachePolicy
  let context: UnsafeMutableRawPointer?
  let resultHandler: GraphQLResultWithContextHandler<Query.Data>
  
  private var networkTask: Cancellable?
  
  init(client: ApolloClient,
       query: Query,
       cachePolicy: CachePolicy,
       context: UnsafeMutableRawPointer?,
       resultHandler: @escaping GraphQLResultWithContextHandler<Query.Data>) {
    self.client = client
    self.query = query
    self.cachePolicy = cachePolicy
    self.context = context
    self.resultHandler = resultHandler
  }
  
  override public func start() {
    if isCancelled {
      state = .finished
      return
    }
    
    state = .executing
    
    if cachePolicy == .fetchIgnoringCacheData {
      fetchFromNetwork()
      return
    }
    
    client?.store.load(query: query) { result in
      if self.isCancelled {
        self.state = .finished
        return
      }
      
      switch result {
      case .success:
        self.resultHandler(result)
        
        if self.cachePolicy != .returnCacheDataAndFetch {
          self.state = .finished
          return
        }
      case .failure:
        if self.cachePolicy == .returnCacheDataDontFetch {
          self.resultHandler(result)
          self.state = .finished
          return
        }
      }
      
      self.fetchFromNetwork()
    }
  }
  
  func fetchFromNetwork() {
    networkTask = client?.send(operation: query,
                               shouldPublishResultToStore: true,
                               context: context) { result in
      self.resultHandler(result)
      self.state = .finished
      return
    }
  }
  
  override public func cancel() {
    super.cancel()
    networkTask?.cancel()
  }
}
