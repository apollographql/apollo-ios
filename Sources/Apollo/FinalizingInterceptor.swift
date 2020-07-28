import Foundation

class FinalizingInterceptor: ApolloInterceptor {
  
  var isCancelled: Bool = false
  
  enum FinalizationError: Error {
    case nilParsedValue(httpResponse: HTTPURLResponse?, rawData: Data?, sourceType: FetchSourceType)
  }
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    
    guard !isCancelled else {
      return
    }
    
    guard let parsed = response.parsedResponse else {
      chain.handleErrorAsync(FinalizationError.nilParsedValue(httpResponse: response.httpResponse,
                                                              rawData: response.rawData,
                                                              sourceType: response.sourceType),
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    completion(.success(parsed))
  }
}
