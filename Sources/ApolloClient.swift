import Foundation

public protocol Cancellable {
  func cancel()
}

public enum CachePolicy {
  case returnCacheDataElseFetch
  case fetchIgnoringCacheData
  case returnCacheDataDontFetch
}

public typealias OperationCompletionHandler<Operation: GraphQLOperation> = (GraphQLResult<Operation.Data>?, Error?) -> Void

public class ApolloClient {
  private let operationQueue: OperationQueue
  
  let networkTransport: NetworkTransport
  let store: ApolloStore
  
  public var cacheKeyForObject: CacheKeyForObject?

  public init(networkTransport: NetworkTransport, store: ApolloStore = ApolloStore()) {
    operationQueue = OperationQueue()
    self.networkTransport = networkTransport
    self.store = store
  }

  public convenience init(url: URL) {
    self.init(networkTransport: HTTPNetworkTransport(url: url))
  }

  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping OperationCompletionHandler<Query>) -> Cancellable {
    if cachePolicy == .fetchIgnoringCacheData {
      return send(operation: query) { (result, error) in
        queue.async {
          completionHandler(result, error)
        }
      }
    } else {
      let operation = FetchQueryOperation(client: self, query: query, cachePolicy: cachePolicy) { (result, error) in
        queue.async {
          completionHandler(result, error)
        }
      }

      operationQueue.addOperation(operation)
      return operation
    }
  }
  
  public func watch<Query: GraphQLQuery>(query: Query, queue: DispatchQueue = DispatchQueue.main, handler: @escaping OperationCompletionHandler<Query>) -> Cancellable {
    return fetch(query: query, queue: queue, completionHandler: handler)
  }
  
  @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping OperationCompletionHandler<Mutation>) -> Cancellable {
    return send(operation: mutation) { (result, error) in
      queue.async {
        completionHandler(result, error)
      }
    }
  }

  fileprivate func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping OperationCompletionHandler<Operation>) -> Cancellable {
    return networkTransport.send(operation: operation) { (response, error) in
      guard let response = response else {
        completionHandler(nil, error)
        return
      }
      
      DispatchQueue.global(qos: .default).async {
        do {
          let normalizer = GraphQLResultNormalizer()
          normalizer.cacheKeyForObject = self.cacheKeyForObject
          
          let result = try response.parseResult(delegate: normalizer)
          
          self.store.publish(changedRecords: normalizer.records)
          
          completionHandler(result, nil)
        } catch {
          completionHandler(nil, error)
        }
      }
    }
  }
}

private final class FetchQueryOperation<Query: GraphQLQuery>: AsynchronousOperation, Cancellable {
  unowned let client: ApolloClient
  let query: Query
  let cachePolicy: CachePolicy
  let completionHandler: OperationCompletionHandler<Query>
  
  private var networkTask: Cancellable?
  
  init(client: ApolloClient, query: Query, cachePolicy: CachePolicy, completionHandler: @escaping OperationCompletionHandler<Query>) {
    self.client = client
    self.query = query
    self.cachePolicy = cachePolicy
    self.completionHandler = completionHandler
  }
  
  override public func start() {
    if isCancelled {
      state = .finished
      return
    }
    
    state = .executing
    
    if cachePolicy != .fetchIgnoringCacheData {
      if let data = try? client.store.load(query: query) {
        completionHandler(GraphQLResult(data: data, errors: nil), nil)
        state = .finished
        return
      }
    }
    
    if isCancelled {
      state = .finished
      return
    }
    
    if cachePolicy == .returnCacheDataDontFetch {
      completionHandler(nil, nil)
      state = .finished
      return
    }
    
    networkTask = client.send(operation: query) { (result, error) in
      self.completionHandler(result, error)
      self.state = .finished
      return
    }
  }
  
  override public func cancel() {
    super.cancel()
    networkTask?.cancel()
  }
}
