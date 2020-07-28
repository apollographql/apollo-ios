import Foundation

public class LegacyCacheWriteInterceptor: ApolloInterceptor {
  
  public let store: ApolloStore
  
  public init(store: ApolloStore) {
    self.store = store
  }
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    
    guard request.cachePolicy != .fetchIgnoringCacheCompletely else {
      // If we're ignoring the cache completely, we're not writing to it.
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
      return
    }
    
    guard let data = response.rawData else {
      chain.handleErrorAsync(ParserError.nilData,
                             request: request,
                             response: response,
                             completion: completion)
      return
    }

    do {
      // TODO: There's got to be a better way to do this than deserializing again
      let json = try JSONSerializationFormat.deserialize(data: data) as? JSONObject
      guard let body = json else {
        throw ParserError.couldNotParseToLegacyJSON
      }
      
      let graphQLResponse = GraphQLResponse(operation: request.operation, body: body)
      firstly {
        try graphQLResponse.parseResult(cacheKeyForObject: self.store.cacheKeyForObject)
      }.andThen { [weak self] (result, records) in
        guard let self = self else {
          return
        }
        guard chain.isNotCancelled else {
          return
        }
        
        if let records = records {
          self.store.publish(records: records)
            .catch { error in
              preconditionFailure(String(describing: error))
          }
        }
        completion(.success(result as! ParsedValue))
      }.catch { error in
        chain.handleErrorAsync(error,
                               request: request,
                               response: response,
                               completion: completion)
      }
      
    } catch {
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
    }
  }
}
