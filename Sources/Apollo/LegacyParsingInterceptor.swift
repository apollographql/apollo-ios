import Foundation

public class LegacyParsingInterceptor: ApolloInterceptor {
  public var isCancelled: Bool = false
  
  public func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    guard !self.isCancelled else {
      return
    }
    
    guard let data = response.rawData else {
      completion(.failure(ParserError.nilData))
      return
    }
    
    do {
      let json = try JSONSerializationFormat.deserialize(data: data) as? JSONObject
      guard let body = json else {
        throw ParserError.couldNotParseToLegacyJSON
      }
      
      let graphQLResponse = GraphQLResponse(operation: request.operation, body: body)
      let parsedResult = try graphQLResponse.parseResultFast()
      let typedResult = parsedResult as! ParsedValue      
      response.parsedResponse = typedResult
      
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
      
    } catch {
      completion(.failure(error))
    }
  }
}
