import Foundation

/// A transport-level, HTTP-specific error.
public struct GraphQLHTTPResponseError: Error, LocalizedError {
  public enum ErrorKind {
    case errorResponse
    case invalidResponse
    
    var description: String {
      switch self {
      case .errorResponse:
        return "Received error response"
      case .invalidResponse:
        return "Received invalid response"
      }
    }
  }
  
  /// The body of the response.
  public let body: Data?
  /// Information about the response as provided by the server.
  public let response: HTTPURLResponse
  public let kind: ErrorKind
  
  public init(body: Data? = nil, response: HTTPURLResponse, kind: ErrorKind) {
    self.body = body
    self.response = response
    self.kind = kind
  }
  
  public var bodyDescription: String {
    guard let body = body else {
      return "Empty response body"
    }
    
    guard let description = String(data: body, encoding: response.textEncoding ?? .utf8) else {
      return "Unreadable response body"
    }
    
    return description
  }
  
  public var errorDescription: String? {
    return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
  }
}
