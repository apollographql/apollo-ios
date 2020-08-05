import Foundation

/// The last interceptor in a normal chain, which checks that parsing has been completed and returns information to the UI.
public class FinalizingInterceptor: ApolloInterceptor {
    
  enum FinalizationError: Error {
    case nilParsedValue(httpResponse: HTTPURLResponse?, rawData: Data?)
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard let parsed = response.parsedResponse else {
      chain.handleErrorAsync(FinalizationError.nilParsedValue(httpResponse: response.httpResponse,
                                                              rawData: response.rawData),
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    chain.returnValueAsync(for: request,
                           value: parsed,
                           completion: completion)
  }
}
