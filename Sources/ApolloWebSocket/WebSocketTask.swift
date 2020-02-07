#if !COCOAPODS
import Apollo
#endif
import Foundation
import Starscream

/// A task to wrap sending/canceling operations over a websocket.
final class WebSocketTask<Operation: GraphQLOperation>: Cancellable {
  let sequenceNumber : String?
  let transport: WebSocketTransport

  /// Designated initializer
  ///
  /// - Parameter ws: The `WebSocketTransport` to use for this task
  /// - Parameter operation: The `GraphQLOperation` to use
  /// - Parameter completionHandler: A completion handler to fire when the operation has a result.
  init(_ ws: WebSocketTransport,
       _ operation: Operation,
       _ completionHandler: @escaping (_ result: Result<JSONObject, Error>) -> Void) {
    sequenceNumber = ws.sendHelper(operation: operation, resultHandler: completionHandler)
    transport = ws
  }

  public func cancel() {
    if let sequenceNumber = sequenceNumber {
      transport.unsubscribe(sequenceNumber)
    }
  }

  // Unsubscribes from further results from this task.
  public func unsubscribe() {
    cancel()
  }
}
