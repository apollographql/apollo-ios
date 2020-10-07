import Foundation
import ApolloCore

/// A protocol to allow fetching of raw data from the network, without
/// doing any error handling at the network level.
public protocol RawNetworkFetcher {
  
  /// A method that will be called when data should be fetched from the network.
  ///
  /// This should generally be called from a custom `NetworkTransport` implementation.
  ///
  /// - Parameter onSuccess: The completion closure to call when data has been successfully fetched from the network.
  func fetchData(onSuccess: (Data) -> Void)
}

/// A class to provide a bridge to allow users with custom `NetworkTransports`
/// who can't switch to `RequestChainNetworkTransport` or a subclass of it to
/// continue to be able to use that transport to hit the cache in the previously
/// expected order.
///
/// A new `RawDataCacheHelper` should be used for each request, so that requests
/// can be cancelled if needed.
public class RawDataCacheHelper {
  
  private var isCancelled = Atomic<Bool>(false)
  private var isNotCancelled: Bool {
    !self.isCancelled.value
  }
  
  /// Designated initializer.
  public init() {}
  
  ///
  /// - Parameters:
  ///   - operation: The operation
  ///   - cachePolicy: The `CachePolicy` to use when fetching.
  ///   - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers.
  ///   - store: The store to use to read and write from
  ///   - networkFetcher: An object
  ///   - completion: The completion closure to execute when parsed data or an error has been received. NOTE: May be called more than once, especially when using the `.returnCacheDataAndFetch` cache policy
  public func sendViaCache<Operation: GraphQLOperation>(
    operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID? = nil,
    store: ApolloStore,
    networkFetcher: RawNetworkFetcher,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    switch cachePolicy {
    case .fetchIgnoringCacheCompletely:
      networkFetcher.fetchData { data in
        self.parseDataFast(data: data,
                           operation: operation,
                           completion: completion)
      }
    case .returnCacheDataElseFetch:
      self.fetchFromStore(store: store,
                          operation: operation) { storeResult in
        switch storeResult {
        case .success(let graphQLResult):
          completion(.success(graphQLResult))
        case .failure:
          networkFetcher.fetchData { data in
            self.parseThenWriteToStore(data: data,
                                       store: store,
                                       operation: operation,
                                       contextIdentifier: contextIdentifier,
                                       completion: completion)
          }
        }
      }
    case .fetchIgnoringCacheData:
      networkFetcher.fetchData { [weak self] data in
        self?.parseThenWriteToStore(data: data,
                                    store: store,
                                    operation: operation,
                                    contextIdentifier: contextIdentifier,
                                    completion: completion)
      }
    case .returnCacheDataDontFetch:
      self.fetchFromStore(store: store,
                          operation: operation,
                          completion: completion)
    case .returnCacheDataAndFetch:
      self.fetchFromStore(
        store: store,
        operation: operation) { storeResult in
        switch storeResult {
        case .failure:
          // Don't return the error here, just proceed
          break
        case .success(let result):
          // Return result, THEN proceed.
          completion(.success(result))
        }
        
        networkFetcher.fetchData { [weak self] data in
          self?.parseThenWriteToStore(data: data,
                                      store: store,
                                      operation: operation,
                                      contextIdentifier: contextIdentifier,
                                      completion: completion)
        }
      }
    }
  }
  
  private func parseThenWriteToStore<Operation: GraphQLOperation>(
    data: Data,
    store: ApolloStore,
    operation: Operation,
    contextIdentifier: UUID?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    self.parseData(
      data: data,
      operation: operation,
      cacheKeyForObject: store.cacheKeyForObject,
      completion: { [weak self] result in
        switch result {
        case .failure(let error):
          completion(.failure(error))
        case .success(let (result, recordSet)):
          self?.writeToStore(store: store,
                             operation: operation,
                             contextIdentifier: contextIdentifier,
                             recordSet: recordSet,
                             result: result,
                             completion: completion)
        }
      })
  }
  
  // MARK: - Cache Fetch
  
  private func fetchFromStore<Operation: GraphQLOperation>(
    store: ApolloStore,
    operation: Operation,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard self.isNotCancelled else {
      return
    }
    
    store.load(query: operation, resultHandler: completion)
  }
  
  // MARK: - Parsing
  
  private func deserialize<Operation: GraphQLOperation>(
    data: Data,
    operation: Operation) throws -> GraphQLResponse<Operation.Data> {
   
    let deserialized = try JSONSerializationFormat.deserialize(data: data)
    guard let body = deserialized as? JSONObject else {
      throw LegacyParsingInterceptor.LegacyParsingError.couldNotParseToLegacyJSON(data: data)
    }
  
    return GraphQLResponse(operation: operation, body: body)
  }
  
  private func parseDataFast<Operation: GraphQLOperation>(
    data: Data,
    operation: Operation,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard self.isNotCancelled else {
      return
    }
    
    do {
      let graphQLResponse = try self.deserialize(data: data, operation: operation)
      let result = try graphQLResponse.parseResultFast()
      completion(.success(result))
    } catch {
      completion(.failure(error))
    }
  }
  
  private func parseData<Operation: GraphQLOperation>(
    data: Data,
    operation: Operation,
    cacheKeyForObject: CacheKeyForObject?,
    completion: @escaping (Result<(GraphQLResult<Operation.Data>, RecordSet?), Error>) -> Void) {
    
    guard self.isNotCancelled else {
      return
    }
    
    do {
      let graphQLResponse = try self.deserialize(data: data, operation: operation)
      graphQLResponse.parseResultWithCompletion(cacheKeyForObject: cacheKeyForObject,
                                                completion: completion)
    } catch {
      completion(.failure(error))
    }
  }
  
  // MARK: - Cache Write
  
  private func writeToStore<Operation: GraphQLOperation>(
    store: ApolloStore,
    operation: Operation,
    contextIdentifier: UUID?,
    recordSet: RecordSet?,
    result: GraphQLResult<Operation.Data>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
      
    guard self.isNotCancelled else {
      return
    }
    
    guard let records = recordSet else {
      return
    }
      
    store.publishWithCompletion(recordSet: records, identifier: contextIdentifier) { publishResult in
      switch publishResult {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        completion(.success(result))
      }
    }
  }
}

extension RawDataCacheHelper: Cancellable {
  
  public func cancel() {
    self.isCancelled.value = true
  }
}
