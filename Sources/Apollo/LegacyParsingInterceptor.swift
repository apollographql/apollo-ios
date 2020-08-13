import Foundation

/// An interceptor which parses code using the legacy parsing system.
public class LegacyParsingInterceptor: ApolloInterceptor {
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard let createdResponse = response else {
        chain.handleErrorAsync(ParserError.noResponseToParse,
                               request: request,
                               response: response,
                               completion: completion)
      return
    }
    
    do {
      let json = try JSONSerializationFormat.deserialize(data: createdResponse.rawData) as? JSONObject
      guard let body = json else {
        throw ParserError.couldNotParseToLegacyJSON
      }
      
      let graphQLResponse = GraphQLResponse(operation: request.operation, body: body)
      let parsedResult = try graphQLResponse.parseResultFast()
      let typedResult = parsedResult
      
      createdResponse.parsedResponse = typedResult
      
      chain.proceedAsync(request: request,
                         response: createdResponse,
                         completion: completion)
      
    } catch {
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
    }
  }
}
