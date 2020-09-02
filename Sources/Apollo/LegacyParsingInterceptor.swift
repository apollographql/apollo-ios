import Foundation

/// An interceptor which parses code using the legacy parsing system.
public class LegacyParsingInterceptor: ApolloInterceptor {
  public enum LegacyParsingError: Error {
    case noResponseToParse
    case couldNotParseToLegacyJSON(data: Data)
  }
  
  public var cacheKeyForObject: CacheKeyForObject?

  /// Designated Initializer
  public init(cacheKeyForObject: CacheKeyForObject? = nil) {
    self.cacheKeyForObject = cacheKeyForObject
  }
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    
    guard let createdResponse = response else {
        chain.handleErrorAsync(LegacyParsingError.noResponseToParse,
                               request: request,
                               response: response,
                               completion: completion)
      return
    }
    
    do {
      let deserialized = try? JSONSerializationFormat.deserialize(data: createdResponse.rawData)
      let json = deserialized as? JSONObject
      guard let body = json else {
        throw LegacyParsingError.couldNotParseToLegacyJSON(data: createdResponse.rawData)
      }
      
      let graphQLResponse = GraphQLResponse(operation: request.operation, body: body)
      createdResponse.legacyResponse = graphQLResponse
      
      switch request.cachePolicy {
      case .fetchIgnoringCacheCompletely:
        // There is no cache, so we don't need to get any info on dependencies. Use fast parsing.
        let fastResult = try graphQLResponse.parseResultFast()
        createdResponse.parsedResponse = fastResult
        chain.proceedAsync(request: request,
                           response: createdResponse,
                           completion: completion)
      default:
        graphQLResponse.parseResultWithCompletion(cacheKeyForObject: self.cacheKeyForObject) { parsingResult in
          switch parsingResult {
          case .failure(let error):
            chain.handleErrorAsync(error,
                                   request: request,
                                   response: createdResponse,
                                   completion: completion)
          case .success(let (parsedResult, _)):
            createdResponse.parsedResponse = parsedResult
            chain.proceedAsync(request: request,
                               response: createdResponse,
                               completion: completion)
          }
        }
      }
    } catch {
      chain.handleErrorAsync(error,
                             request: request,
                             response: response,
                             completion: completion)
    }
  }
}
