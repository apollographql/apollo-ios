import Foundation

class ParsingInterceptor<FlexDecoder: FlexibleDecoder>: ApolloInterceptor {
  enum ParserError: Error {
    case nilData
  }
  
  let decoder: FlexDecoder
  
  var isCancelled: Bool = false
  
  public init(decoder: FlexDecoder) {
    self.decoder = decoder
  }
  
  func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    chain: RequestChain<ParsedValue, Operation>,
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
      let parsedData = try ParsedValue(from: data, decoder: self.decoder)
      response.parsedResponse = parsedData
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
    } catch {
      completion(.failure(error))
    }
  }
}
