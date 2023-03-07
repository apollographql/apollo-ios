import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor to check the response code returned with a request.
public struct ResponseCodeInterceptor: ApolloInterceptor {
  
  public enum ResponseCodeError: Error, LocalizedError {
    case invalidResponseCode(response: HTTPURLResponse?, rawData: Data?, jsonObject: JSONObject?)
    
    public var errorDescription: String? {
      switch self {
      case .invalidResponseCode(let response, let rawData, _):
        var errorStrings = [String]()
        if let code = response?.statusCode {
          errorStrings.append("Received a \(code) error.")
        } else {
          errorStrings.append("Did not receive a valid status code.")
        }
        
        if
          let data = rawData,
          let dataString = String(bytes: data, encoding: .utf8) {
          errorStrings.append("Data returned as a String was:")
          errorStrings.append(dataString)
        } else {
          errorStrings.append("Data was nil or could not be transformed into a string.")
        }
        
        return errorStrings.joined(separator: " ")
      }
    }
  }
  
  /// Designated initializer
  public init() {}
  
  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
      guard response?.httpResponse.isSuccessful == true else {
        var jsonObject: JSONObject?
        if let data = response?.rawData {
          jsonObject = try? JSONSerialization.jsonObject(with: data) as? JSONObject
        }
        
        let error = ResponseCodeError.invalidResponseCode(
          response: response?.httpResponse,
          rawData: response?.rawData,
          jsonObject: jsonObject
        )
        
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
