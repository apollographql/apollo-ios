import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor which parses JSON response data into a `GraphQLResult` and attaches it to the `HTTPResponse`.
public struct JSONResponseParsingInterceptor: ApolloInterceptor {
  
  public enum JSONResponseParsingError: Error, LocalizedError {
    case noResponseToParse
    case couldNotParseToJSON(data: Data)
    
    public var errorDescription: String? {
      switch self {
      case .noResponseToParse:
        return "The Codable Parsing Interceptor was called before a response was received to be parsed. Double-check the order of your interceptors."
      case .couldNotParseToJSON(let data):
        var errorStrings = [String]()
        errorStrings.append("Could not parse data to JSON format.")
        if let dataString = String(bytes: data, encoding: .utf8) {
          errorStrings.append("Data received as a String was:")
          errorStrings.append(dataString)
        } else {
          errorStrings.append("Data of count \(data.count) also could not be parsed into a String.")
        }
        
        return errorStrings.joined(separator: " ")
      }
    }
  }

  public var id: String = UUID().uuidString

  public init() { }

  public func interceptAsync<Operation: GraphQLOperation>(
    chain: any RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping GraphQLResultHandler<Operation.Data>
  ) {
    guard var createdResponse = response else {
      chain.handleErrorAsync(
        JSONResponseParsingError.noResponseToParse,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    do {
      guard
        let body = try? JSONSerializationFormat.deserialize(data: createdResponse.rawData) as? JSONObject
      else {
        throw JSONResponseParsingError.couldNotParseToJSON(data: createdResponse.rawData)
      }

      let graphQLResponse = GraphQLResponse(operation: request.operation, body: body)

      let (result, cacheRecords) = try graphQLResponse.parseResult(withCachePolicy: request.cachePolicy)
      createdResponse.parsedResponse = result
      createdResponse.cacheRecords = cacheRecords
      
      chain.proceedAsync(
        request: request,
        response: createdResponse,
        interceptor: self,
        completion: completion
      )

    } catch {
      chain.handleErrorAsync(
        error,
        request: request,
        response: createdResponse,
        completion: completion
      )
    }
  }

}
