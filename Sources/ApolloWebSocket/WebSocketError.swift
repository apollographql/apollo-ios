#if !COCOAPODS
import Apollo
#endif
import Foundation

/// A structure for capturing problems and any associated errors from a `WebSocketTransport`.
public struct WebSocketError: Error, LocalizedError {
  public enum ErrorKind {
    case errorResponse
    case networkError
    case unprocessedMessage(String)
    case serializedMessageError
    case neitherErrorNorPayloadReceived
    case upgradeError(code: Int)

    var description: String {
      switch self {
      case .errorResponse:
        return "Received error response"
      case .networkError:
        return "Websocket network error"
      case .unprocessedMessage(let message):
        return "Websocket error: Unprocessed message \(message)"
      case .serializedMessageError:
        return "Websocket error: Serialized message not found"
      case .neitherErrorNorPayloadReceived:
        return "Websocket error: Did not receive an error or a payload."
      case .upgradeError:
        return "Websocket error: Invalid HTTP upgrade."
      }
    }
  }

  /// The payload of the response.
  public let payload: JSONObject?

  /// The underlying error, or nil if one was not returned
  public let error: Error?

  /// The kind of problem which occurred.
  public let kind: ErrorKind

  public var errorDescription: String? {
    return "\(self.kind.description). Error: \(String(describing: self.error))"
  }
}
