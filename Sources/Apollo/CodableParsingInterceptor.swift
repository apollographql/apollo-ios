import Foundation

public class CodableParsingInterceptor<FlexDecoder: FlexibleDecoder>: ApolloInterceptor {
  
  public enum CodableParsingError: Error, LocalizedError {
    case noResponseToParse
    
    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "The Codable Parsing Interceptor was called before a response was received to be parsed. Double-check the order of your interceptors."
      }
    }
  }

  let decoder: FlexDecoder
  
  var isCancelled: Bool = false
  
  public init(decoder: FlexDecoder) {
    self.decoder = decoder
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    guard !self.isCancelled else {
      return
    }
    
    guard let createdResponse = response else {
      chain.handleErrorAsync(CodableParsingError.noResponseToParse,
                             request: request,
                             response: response,
                             completion: completion)
      return
    }
    
    do {
      let parsedData = try GraphQLResult<Operation.Data>(from: createdResponse.rawData, decoder: self.decoder)
      createdResponse.parsedResponse = parsedData
      chain.proceedAsync(request: request,
                         response: response,
                         completion: completion)
    } catch {
      chain.handleErrorAsync(error,
                             request: request,
                             response: createdResponse,
                             completion: completion)
    }
  }
}
