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
    self.init(networkTransport: HTTPNetworkTransport(url: url))
  }

  fileprivate func send<Operation: GraphQLOperation>(operation: Operation,
                                                     shouldPublishResultToStore: Bool,
                                                     context: UnsafeMutableRawPointer?,
                                                     resultHandler: @escaping GraphQLResultHandler<Operation.Data>) -> Cancellable {
    return networkTransport.send(operation: operation) { [weak self] result in
      guard let self = self else {
        return
      }
      self.handleOperationResult(shouldPublishResultToStore: shouldPublishResultToStore,
                                 context: context,
                                 result,
                                 resultHandler: resultHandler)
    }
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
                                                 context: UnsafeMutableRawPointer? = nil,
                                                 queue: DispatchQueue = DispatchQueue.main,
                                                 resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable {
    return self.send(operation: mutation,
                     shouldPublishResultToStore: true,
                     context: context,
                     resultHandler: wrapResultHandler(resultHandler, queue: queue))
  }

  @discardableResult
  public func upload<Operation: GraphQLOperation>(operation: Operation,
                                                  context: UnsafeMutableRawPointer? = nil,
                                                  files: [GraphQLFile],
                                                  queue: DispatchQueue = .main,
                                                  resultHandler: GraphQLResultHandler<Operation.Data>? = nil) -> Cancellable {
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
      self.handleOperationResult(shouldPublishResultToStore: true,
                                 context: context, result,
                                 resultHandler: wrappedHandler)
    }
  }

  @discardableResult
  public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                           queue: DispatchQueue = .main,
                                                           resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable {
    return self.send(operation: subscription,
                     shouldPublishResultToStore: true,
                     context: nil,
                     resultHandler: wrapResultHandler(resultHandler, queue: queue))
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

private final class FetchQueryOperation<Query: GraphQLQuery>: AsynchronousOperation, Cancellable {
  weak var client: ApolloClient?
  let query: Query
  let cachePolicy: CachePolicy
  let context: UnsafeMutableRawPointer?
  let resultHandler: GraphQLResultHandler<Query.Data>

  private var networkTask: Cancellable?

  init(client: ApolloClient,
       query: Query,
       cachePolicy: CachePolicy,
       context: UnsafeMutableRawPointer?,
       resultHandler: @escaping GraphQLResultHandler<Query.Data>) {
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

    client?.store.load(query: query) { [weak self] result in
      guard let self = self else {
        return
      }
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
                               context: context) { [weak self] result in
      guard let self = self else {
        return
      }
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
