#if !COCOAPODS
import Apollo
#endif
import Foundation
import Starscream

final class WebSocketTask<Operation: GraphQLOperation>: Cancellable {
  let sequenceNumber : String?
  let transport: WebSocketTransport
  
  init(_ ws: WebSocketTransport, _ operation: Operation, _ completionHandler: @escaping (_ result: Result<JSONObject, Error>) -> Void) {
    sequenceNumber = ws.sendHelper(operation: operation, resultHandler: completionHandler)
    transport = ws
  }
  
  public func cancel() {
    if let sequenceNumber = sequenceNumber {
      transport.unsubscribe(sequenceNumber)
    }
  }
  
  // unsubscribe same as cancel
  public func unsubscribe() {
    cancel()
  }
}
