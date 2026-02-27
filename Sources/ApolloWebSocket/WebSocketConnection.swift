import ApolloAPI
import Foundation

final class WebSocketConnection: Sendable {

  private let webSocketTask: any WebSocketTask

  init(task: any WebSocketTask) {
    self.webSocketTask = task    
  }

  deinit {
    self.webSocketTask.cancel(with: .goingAway, reason: nil)
  }

  func openConnection(
    connectingPayload: JSONEncodableDictionary? = nil
  ) -> AsyncThrowingStream<URLSessionWebSocketTask.Message, any Swift.Error> {
    do {
      webSocketTask.resume()
      try send(WebSocketTransport.Message.Outgoing.connectionInit(payload: connectingPayload).toWebSocketMessage())

    } catch {
      return AsyncThrowingStream {
        throw error
      }
    }

    return AsyncThrowingStream { [weak self] in
      guard let self else { return nil }

      try Task.checkCancellation()

      do {
        let message = try await self.webSocketTask.receive()
        return Task.isCancelled ? nil : message

      } catch let error as POSIXError where error.code == .ENOTCONN || error.code == .ECONNRESET {
        // Server-initiated disconnection: URLSessionWebSocketTask.receive() throws
        // POSIXError.ENOTCONN (57) on graceful server close and
        // POSIXError.ECONNRESET (54) when the server drops the connection.
        // Convert these to normal stream completion so the transport's receive loop
        // can handle reconnection through its own state machine.
        return nil
      }
    }
  }

  /// Gracefully closes the WebSocket connection by cancelling the underlying task.
  ///
  /// This causes any pending `receive()` call to throw, ending the connection's message stream.
  /// Safe to call multiple times — subsequent calls are no-ops on an already-cancelled task.
  func close(with closeCode: URLSessionWebSocketTask.CloseCode = .goingAway) {
    webSocketTask.cancel(with: closeCode, reason: nil)
  }

  func send(_ message: URLSessionWebSocketTask.Message) {
    Task {
      try await webSocketTask.send(message)
    }
  }

}
