import Foundation

public protocol Cancellable: class {
  func cancel()
}

public enum CachePolicy {
  case returnCacheDataElseFetch
  case fetchIgnoringCacheData
  case returnCacheDataDontFetch
}

public typealias CacheKeyForObject = (JSONObject) -> JSONValue?

public typealias OperationResultHandler<Operation: GraphQLOperation> = (GraphQLResult<Operation.Data>?, Error?) -> Void

public class ApolloClient {
  public var cacheKeyForObject: CacheKeyForObject?
  
  let networkTransport: NetworkTransport
  let store: ApolloStore
  
  private let queue: DispatchQueue
  private let operationQueue: OperationQueue
  
  public init(networkTransport: NetworkTransport, store: ApolloStore = ApolloStore()) {
    self.networkTransport = networkTransport
    self.store = store
    
    queue = DispatchQueue(label: "com.apollographql.ApolloClient", attributes: .concurrent)
    operationQueue = OperationQueue()
  }

  public convenience init(url: URL) {
    self.init(networkTransport: HTTPNetworkTransport(url: url))
  }
  
  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, handlerQueue: DispatchQueue = DispatchQueue.main, resultHandler: OperationResultHandler<Query>? = nil) -> Cancellable {
    return _fetch(query: query, cachePolicy: cachePolicy, handlerQueue: handlerQueue, resultHandler: resultHandler)
  }
  
  func _fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy, context: UnsafeMutableRawPointer? = nil, handlerQueue: DispatchQueue, resultHandler: OperationResultHandler<Query>?) -> Cancellable {
    // If we don't have to go through the cache, there is no need to create an operation 
    // and we can return a network task directly
    if cachePolicy == .fetchIgnoringCacheData {
      return send(operation: query, context: context, handlerQueue: handlerQueue, resultHandler: resultHandler)
    } else {
      let operation = FetchQueryOperation(client: self, query: query, cachePolicy: cachePolicy, context: context, handlerQueue: handlerQueue, resultHandler: resultHandler)
      operationQueue.addOperation(operation)
      return operation
    }
  }
  
  public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, handlerQueue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping OperationResultHandler<Query>) -> GraphQLQueryWatcher<Query> {
    let watcher = GraphQLQueryWatcher(client: self, query: query, handlerQueue: handlerQueue, resultHandler: resultHandler)
    watcher.fetch(cachePolicy: cachePolicy)
    return watcher
  }
  
  @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation, context: UnsafeMutableRawPointer? = nil, handlerQueue: DispatchQueue = DispatchQueue.main, resultHandler: OperationResultHandler<Mutation>?) -> Cancellable {
    return send(operation: mutation, context: context, handlerQueue: handlerQueue, resultHandler: resultHandler)
  }

  fileprivate func send<Operation: GraphQLOperation>(operation: Operation, context: UnsafeMutableRawPointer?,handlerQueue: DispatchQueue, resultHandler: OperationResultHandler<Operation>?) -> Cancellable {
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
