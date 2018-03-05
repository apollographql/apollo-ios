//
//  SplitNetworkTransport.swift
//
import Foundation

public class SplitNetworkTransport: NetworkTransport {
    private let httpNetworkTransport: NetworkTransport
    private let webSocketNetworkTransport: NetworkTransport
    
    public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport) {
        self.httpNetworkTransport = httpNetworkTransport
        self.webSocketNetworkTransport = webSocketNetworkTransport
    }
    
    public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
        if operation.operationType == .subscription {
            return webSocketNetworkTransport.send(operation: operation, completionHandler: completionHandler)
        } else {
          return httpNetworkTransport.send(operation: operation, completionHandler: completionHandler)
        }
    }
}

