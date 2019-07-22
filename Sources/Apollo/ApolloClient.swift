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

/// A handler for operation results.
///
/// - Parameters:
///   - result: The result of the performed operation, or `nil` if an error occurred.
///   - error: An error that indicates why the mutation failed, or `nil` if the mutation was succesful.
public typealias GraphQLResultHandler<Data> = (_ result: GraphQLResult<Data>?, _ error: Error?) -> Void

@available(*, deprecated, renamed: "GraphQLResultHandler")
public typealias OperationResultHandler<Operation: GraphQLOperation> = GraphQLResultHandler<Operation.Data>

/// The `ApolloClient` class provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.
public class ApolloClient {
  let networkTransport: NetworkTransport
    
  public let store: ApolloStore
    
  public var cacheKeyForObject: CacheKeyForObject? {
    get {
      return store.cacheKeyForObject
    }
    
    set {
      store.cacheKeyForObject = newValue
    }
  }
    
  private let queue: DispatchQueue
  private let operationQueue: OperationQueue
  
  /// Creates a client with the specified network transport and store.
  ///
  /// - Parameters:
  ///   - networkTransport: A network transport used to send operations to a server.
  ///   - store: A store used as a local cache. Defaults to an empty store backed by an in memory cache.
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

  /// Clears apollo cache
  ///
  /// - Returns: Promise
  public func clearCache() -> Promise<Void> {
    return store.clearCache()
  }
  
  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable {
    let resultHandler = wrapResultHandler(resultHandler, queue: queue)
    
    // If we don't have to go through the cache, there is no need to create an operation
    // and we can return a network task directly
    if cachePolicy == .fetchIgnoringCacheData || cachePolicy == .fetchIgnoringCacheCompletely {
      return send(operation: query, shouldPublishResultToStore: cachePolicy != .fetchIgnoringCacheCompletely, context: context, resultHandler: resultHandler)
    } else {
      let operation = FetchQueryOperation(client: self, query: query, cachePolicy: cachePolicy, context: context, resultHandler: resultHandler)
      operationQueue.addOperation(operation)
      return operation
    }
  }
  
  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  
  public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self, query: query, resultHandler: wrapResultHandler(resultHandler, queue: queue))
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }
  
  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable {
    return send(operation: mutation, shouldPublishResultToStore: true, context: context, resultHandler: wrapResultHandler(resultHandler, queue: queue))
  }

  /// Subscribe to a subscription
  ///
  /// - Parameters:
  ///   - subscription: The subscription to subscribe to.
  ///   - fetchHTTPMethod: The HTTP Method to be used.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  /// - Returns: An object that can be used to cancel an in progress subscription.
  @discardableResult public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable {
    return send(operation: subscription, shouldPublishResultToStore: true, context: nil, resultHandler: wrapResultHandler(resultHandler, queue: queue))
  }
  
  fileprivate func send<Operation: GraphQLOperation>(operation: Operation, shouldPublishResultToStore: Bool, context: UnsafeMutableRawPointer?, resultHandler: @escaping GraphQLResultHandler<Operation.Data>) -> Cancellable {
    return networkTransport.send(operation: operation) { (response, error) in
      guard let response = response else {
        resultHandler(nil, error)
        return
      }
      
      // If there is no need to publish the result to the store, we can use a fast path.
      if !shouldPublishResultToStore {
        do {
          let result = try response.parseResultFast()
          resultHandler(result, nil)
        } catch {
          resultHandler(nil, error)
        }
        return
      }
      
      firstly {
        try response.parseResult(cacheKeyForObject: self.cacheKeyForObject)
      }.andThen { (result, records) in
        if let records = records {
          self.store.publish(records: records, context: context).catch { error in
            preconditionFailure(String(describing: error))
          }
        }
        resultHandler(result, nil)
      }.catch { error in
        resultHandler(nil, error)
      }
    }
  }
}

private func wrapResultHandler<Data>(_ resultHandler: GraphQLResultHandler<Data>?, queue handlerQueue: DispatchQueue) -> GraphQLResultHandler<Data> {
  guard let resultHandler = resultHandler else {
    return { _, _ in }
  }
  
  return { (result, error) in
    handlerQueue.async {
      resultHandler(result, error)
    }
  }
}

private final class FetchQueryOperation<Query: GraphQLQuery>: AsynchronousOperation, Cancellable {
  let client: ApolloClient
  let query: Query
  let cachePolicy: CachePolicy
  let context: UnsafeMutableRawPointer?
  let resultHandler: GraphQLResultHandler<Query.Data>
  
  private var networkTask: Cancellable?
  
  init(client: ApolloClient, query: Query, cachePolicy: CachePolicy, context: UnsafeMutableRawPointer?, resultHandler: @escaping GraphQLResultHandler<Query.Data>) {
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
    
    client.store.load(query: query) { (result, error) in
      if error == nil {
        self.resultHandler(result, nil)
        
        if self.cachePolicy != .returnCacheDataAndFetch {
          self.state = .finished
          return
        }
      }
      
      if self.isCancelled {
        self.state = .finished
        return
      }
      
      if self.cachePolicy == .returnCacheDataDontFetch {
        self.resultHandler(nil, nil)
        self.state = .finished
        return
      }
      
      self.fetchFromNetwork()
    }
  }
  
  func fetchFromNetwork() {
    networkTask = client.send(operation: query, shouldPublishResultToStore: true, context: context) { (result, error) in
      self.resultHandler(result, error)
      self.state = .finished
      return
    }
  }
  
  override public func cancel() {
    super.cancel()
    networkTask?.cancel()
  }
}
