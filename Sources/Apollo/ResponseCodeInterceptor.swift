import Foundation

/// An interceptor to check the response code returned with a request.
public class ResponseCodeInterceptor: ApolloInterceptor {
  
  enum ResponseCodeError: Error {
    case invalidResponseCode(response: HTTPURLResponse?, rawData: Data?)
  }
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    
    guard response.httpResponse?.apollo.isSuccessful == true else {
      let error = ResponseCodeError.invalidResponseCode(response: response.httpResponse,
                                                        
                                                        rawData: response.rawData)
      
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    chain.proceedAsync(request: request,
                       response: response,
                       completion: completion)
  }
}
