import Foundation

/// A transport-level, HTTP-specific error.
public struct GraphQLHTTPResponseError: Error, LocalizedError {
  public enum ErrorKind {
    case errorResponse
    case invalidResponse
    case persistedQueryNotFound
    case persistedQueryNotSupported

    public var description: String {
      switch self {
      case .errorResponse:
        return "Received error response"
      case .invalidResponse:
        return "Received invalid response"
      case .persistedQueryNotFound:
        return "Persisted query not found"
      case .persistedQueryNotSupported:
        return "Persisted query not supported"
      }
    }
  }

  /// The body of the response.
  public let body: Data?
  /// Information about the response as provided by the server.
  public let response: HTTPURLResponse
  public let kind: ErrorKind
  private let serializationFormat = JSONSerializationFormat.self

  public init(body: Data? = nil,
              response: HTTPURLResponse,
              kind: ErrorKind) {
    self.body = body
    self.response = response
    self.kind = kind
  }

  /// Any graphQL errors that could be parsed from the response, or nil if none could be parsed.
  public var graphQLErrors: [GraphQLError]? {
    guard
      let data = self.body,
      let json = try? self.serializationFormat.deserialize(data: data) as? JSONObject,
      let errorArray = json["errors"] as? [JSONObject] else {
        return nil
    }

    let parsedErrors = errorArray.compactMap { GraphQLError($0) }
    return parsedErrors
  }

  public var bodyDescription: String {
    guard let body = body else {
      return "[Empty response body]"
    }

    guard let description = String(data: body, encoding: response.textEncoding ?? .utf8) else {
      return "[Unreadable response body]"
    }

    return description
  }

  public var errorDescription: String? {
    if let errorArray = self.graphQLErrors {
      let descriptions = errorArray.map { $0.localizedDescription }
      let description = descriptions.joined(separator: "\n")

      return "\(kind.description): \(description)"
    } else {
      return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
    }
  }
}
