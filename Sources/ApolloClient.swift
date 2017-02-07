import Foundation

/// An object that can be used to cancel an in progress action.
public protocol Cancellable: class {
  /// Cancel an in progress action.
  func cancel()
}

/// A cache policy that specifies whether results should be fetched from the server or loaded from the local cache.
public enum CachePolicy {
  /// Return data from the cache if available, else fetch results from the server.
  case returnCacheDataElseFetch
  ///  Always fetch results from the server.
  case fetchIgnoringCacheData
  /// Return data from the cache if available, else return nil.
  case returnCacheDataDontFetch
}

/// A function that returns a cache key for a particular result object. If it returns `nil`, a default cache key based on the field path will be used.
public typealias CacheKeyForObject = (_ object: JSONObject) -> JSONValue?

public typealias OperationResultHandler<Operation: GraphQLOperation> = (_ result: GraphQLResult<Operation.Data>?, _ error: Error?) -> Void

/// The `ApolloClient` class provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.
public class ApolloClient {
  public var cacheKeyForObject: CacheKeyForObject?
  
  let networkTransport: NetworkTransport
  let store: ApolloStore
  
  private let queue: DispatchQueue
  private let operationQueue: OperationQueue
  
  /// Creates a client with the specified network transport and store.
  ///
  /// - Parameters:
  ///   - networkTransport: A network transport used to send operations to a server.
  ///   - store: A store used as a local cache. Defaults to an empty store.
  public init(networkTransport: NetworkTransport, store: ApolloStore = ApolloStore()) {
    self.networkTransport = networkTransport
    self.store = store
    
    queue = DispatchQueue(label: "com.apollographql.ApolloClient", attributes: .concurrent)
    operationQueue = OperationQueue()
  }

  /// Creates a client with an HTTP network transport connecting to the specified URL.
  ///
  /// - Parameter url: The URL of a GraphQL server to connect to.
  public convenience init(url: URL) {
    self.init(networkTransport: HTTPNetworkTransport(url: url))
  }
  
  /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
  ///   - result: The result of the fetched query, or `nil` if an error occurred.
  ///   - error: An error that indicates why the fetch failed, or `nil` if the fetch was succesful.
  /// - Returns: An object that can be used to cancel an in progress fetch.
  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: OperationResultHandler<Query>? = nil) -> Cancellable {
    return _fetch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: resultHandler)
  }
  
  func _fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue, resultHandler: OperationResultHandler<Query>?) -> Cancellable {
    // If we don't have to go through the cache, there is no need to create an operation 
    // and we can return a network task directly
    if cachePolicy == .fetchIgnoringCacheData {
      return send(operation: query, context: context, handlerQueue: queue, resultHandler: resultHandler)
    } else {
      let operation = FetchQueryOperation(client: self, query: query, cachePolicy: cachePolicy, context: context, handlerQueue: queue, resultHandler: resultHandler)
      operationQueue.addOperation(operation)
      return operation
    }
  }
  
  /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
  ///
  /// - Parameters:
  ///   - query: The query to fetch.
  ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
  ///   - result: The result of the fetched query, or `nil` if an error occurred.
  ///   - error: An error that indicates why the fetch failed, or `nil` if the fetch was succesful.
  /// - Returns: A query watcher object that can be used to control the watching behavior.
  public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping OperationResultHandler<Query>) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self, query: query, handlerQueue: queue, resultHandler: resultHandler)
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }
  
  /// Performs a mutation by sending it to the server.
  ///
  /// - Parameters:
  ///   - mutation: The mutation to perform.
  ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
  ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
  ///   - result: The result of the performed mutation, or `nil` if an error occurred.
  ///   - error: An error that indicates why the mutation failed, or `nil` if the mutation was succesful.
  /// - Returns: An object that can be used to cancel an in progress mutation.
  @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, resultHandler: OperationResultHandler<Mutation>?) -> Cancellable {
    return _perform(mutation: mutation, queue: queue, resultHandler: resultHandler)
  }
  
  func _perform<Mutation: GraphQLMutation>(mutation: Mutation, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue, resultHandler: OperationResultHandler<Mutation>?) -> Cancellable {
    return send(operation: mutation, context: context, handlerQueue: queue, resultHandler: resultHandler)
  }

  fileprivate func send<Operation: GraphQLOperation>(operation: Operation, context: UnsafeMutableRawPointer?, handlerQueue: DispatchQueue, resultHandler: OperationResultHandler<Operation>?) -> Cancellable {
    func notifyResultHandler(result: GraphQLResult<Operation.Data>?, error: Error?) {
      guard let resultHandler = resultHandler else { return }
      
      handlerQueue.async {
        resultHandler(result, error)
      }
    }
    
    return networkTransport.send(operation: operation) { (response, error) in
      guard let response = response else {
        notifyResultHandler(result: nil, error: error)
        return
      }
      
      self.queue.async {
        do {
          let (result, records) = try response.parseResult(cacheKeyForObject: self.cacheKeyForObject)
          
          notifyResultHandler(result: result, error: nil)
          
          if let records = records {
            self.store.publish(records: records, context: context)
          }
        } catch {
          notifyResultHandler(result: nil, error: error)
        }
      }
    }
  }
}

private final class FetchQueryOperation<Query: GraphQLQuery>: AsynchronousOperation, Cancellable {
  unowned let client: ApolloClient
  let query: Query
  let cachePolicy: CachePolicy
  let context: UnsafeMutableRawPointer?
  let handlerQueue: DispatchQueue
  let resultHandler: OperationResultHandler<Query>?
  
  private var networkTask: Cancellable?
  
  init(client: ApolloClient, query: Query, cachePolicy: CachePolicy, context: UnsafeMutableRawPointer?, handlerQueue: DispatchQueue, resultHandler: OperationResultHandler<Query>?) {
    self.client = client
    self.query = query
    self.cachePolicy = cachePolicy
    self.context = context
    self.handlerQueue = handlerQueue
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
    
    client.store.load(query: query, cacheKeyForObject: client.cacheKeyForObject) { (result, error) in
      if error == nil {
        self.notifyResultHandler(result: result, error: nil)
        self.state = .finished
        return
      }
      
      if self.isCancelled {
        self.state = .finished
        return
      }
      
      if self.cachePolicy == .returnCacheDataDontFetch {
        self.notifyResultHandler(result: nil, error: nil)
        self.state = .finished
        return
      }
      
      self.fetchFromNetwork()
    }
  }
  
  func fetchFromNetwork() {
    networkTask = client.send(operation: query, context: context, handlerQueue: handlerQueue) { (result, error) in
      self.notifyResultHandler(result: result, error: error)
      self.state = .finished
      return
    }
  }
  
  override public func cancel() {
    super.cancel()
    networkTask?.cancel()
  }
  
  func notifyResultHandler(result: GraphQLResult<Query.Data>?, error: Error?) {
    guard let resultHandler = resultHandler else { return }
    
    handlerQueue.async {
      resultHandler(result, error)
    }
  }
}
