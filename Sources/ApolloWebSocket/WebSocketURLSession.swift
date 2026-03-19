import Foundation

/// An abstraction over `URLSessionWebSocketTask` to allow mocking in tests.
///
/// `URLSessionWebSocketTask` cannot be directly instantiated outside of `URLSession`,
/// so this protocol allows test doubles to be injected in its place.
public protocol WebSocketTask: Sendable {
  func resume()
  func send(_ message: URLSessionWebSocketTask.Message) async throws
  func receive() async throws -> URLSessionWebSocketTask.Message
  func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension URLSessionWebSocketTask: WebSocketTask {}

public protocol WebSocketURLSession: Sendable {
  func webSocketTask(with request: URLRequest) -> any WebSocketTask
}

extension URLSession: WebSocketURLSession {
  public func webSocketTask(with request: URLRequest) -> any WebSocketTask {
    let task: URLSessionWebSocketTask = webSocketTask(with: request)
    return task
  }
}
