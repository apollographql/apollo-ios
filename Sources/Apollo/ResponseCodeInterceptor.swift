import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// An interceptor to check the response code returned with a request.
public struct ResponseCodeInterceptor: ApolloInterceptor {

  public var id: String = UUID().uuidString
  
  public enum ResponseCodeError: Error, LocalizedError {
    case invalidResponseCode(response: HTTPURLResponse?, rawData: Data?)
    
    public var errorDescription: String? {
      switch self {
      case .invalidResponseCode(let response, let rawData):
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
      let error = ResponseCodeError.invalidResponseCode(
        response: response?.httpResponse,
        rawData: response?.rawData
      )
      
      chain.handleErrorAsync(
        error,
        request: request,
        response: response,
        completion: completion
      )
      return
    }
    
      chain.proceedAsync(
        request: request,
        response: response,
        interceptor: self,
        completion: completion
      )
  }
}
