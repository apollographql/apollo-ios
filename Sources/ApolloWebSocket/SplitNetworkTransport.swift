import Apollo

public class SplitNetworkTransport: NetworkTransport {
  private let httpNetworkTransport: NetworkTransport
  private let webSocketNetworkTransport: NetworkTransport
  
  public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport) {
    self.httpNetworkTransport = httpNetworkTransport
    self.webSocketNetworkTransport = webSocketNetworkTransport
  }
  
  public func send<Operation>(operation: Operation, fetchOptions: FetchOptions, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    if operation.operationType == .subscription {
        return webSocketNetworkTransport.send(operation: operation, fetchOptions: fetchOptions, completionHandler: completionHandler)
    } else {
        return httpNetworkTransport.send(operation: operation, fetchOptions: fetchOptions, completionHandler: completionHandler)
    }
  }
}
