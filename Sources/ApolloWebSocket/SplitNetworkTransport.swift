#if !COCOAPODS
import Apollo
#endif


public class SplitNetworkTransport: NetworkTransport {
  private let httpNetworkTransport: NetworkTransport
  private let webSocketNetworkTransport: NetworkTransport
  
  public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport) {
    self.httpNetworkTransport = httpNetworkTransport
    self.webSocketNetworkTransport = webSocketNetworkTransport
  }
  
  public func send<Operation>(operation: Operation, fetchHTTPMethod: FetchHTTPMethod, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    if operation.operationType == .subscription {
        return webSocketNetworkTransport.send(operation: operation, fetchHTTPMethod: fetchHTTPMethod, completionHandler: completionHandler)
    } else {
        return httpNetworkTransport.send(operation: operation, fetchHTTPMethod: fetchHTTPMethod, completionHandler: completionHandler)
    }
  }
}
