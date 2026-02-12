import Foundation

final class WebSocketConnection: NSObject, Sendable, URLSessionWebSocketDelegate {

  //  private unowned let transport: WebSocketTransport
  private let webSocketTask: URLSessionWebSocketTask

  init(task: URLSessionWebSocketTask) {
    self.webSocketTask = task
    super.init()
    task.delegate = self
  }

  deinit {
    self.webSocketTask.cancel(with: .goingAway, reason: nil)
  }

  func openConnection() -> AsyncThrowingStream<URLSessionWebSocketTask.Message, any Swift.Error> {
    do {
      webSocketTask.resume()
      try send(WebSocketTransport.Message.Outgoing.connectionInit(payload: nil).toWebSocketMessage())

    } catch {
      return AsyncThrowingStream {
        throw error
      }
    }

    return AsyncThrowingStream { [weak self] in
      guard let self else { return nil }

      try Task.checkCancellation()

      let message = try await self.webSocketTask.receive()

      return Task.isCancelled ? nil : message
    }
  }

  func send(_ message: URLSessionWebSocketTask.Message) {
    Task {
      try await webSocketTask.send(message)
    }
  }

  // MARK: URLSessionWebSocketDelegate

  func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didOpenWithProtocol protocol: String?
  ) {
    print("did open!")
//    send()
  }

  func urlSession(
    _ session: URLSession,
    webSocketTask: URLSessionWebSocketTask,
    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
    reason: Data?
  ) {
    print("Closed")
    print(closeCode.rawValue)
  }

  func urlSession(
    _ session: URLSession,
    task: URLSessionTask,
    didSendBodyData bytesSent: Int64,
    totalBytesSent: Int64,
    totalBytesExpectedToSend: Int64
  ) {
    print(bytesSent)
  }

  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
    print(error)
  }
}

#warning("TODO")
import Apollo
import ApolloAPI

public protocol GraphQLWebSocketRequest<Operation>: Sendable {
  associatedtype Operation: GraphQLOperation

  /// The GraphQL Operation to execute
  var operation: Operation { get set }

  /// The ``FetchBehavior`` to use for this request.
  /// Determines if fetching will include cache/network.
  var fetchBehavior: FetchBehavior { get set }

  /// Determines if the results of a network fetch should be written to the local cache.
  var writeResultsToCache: Bool { get set }

  /// The timeout interval specifies the limit on the idle interval allotted to a request in the process of
  /// loading. This timeout interval is measured in seconds.
  var requestTimeout: TimeInterval? { get set }
}
