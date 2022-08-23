import Foundation
@testable import ApolloWebSocket

public class MockWebSocket: WebSocketClient {
  
  public var request: URLRequest
  public var callbackQueue: DispatchQueue = DispatchQueue.main
  public var delegate: WebSocketClientDelegate? = nil
  public var isConnected: Bool = false
    
  public required init(request: URLRequest, protocol: WebSocket.WSProtocol) {
    self.request = request

    self.request.setValue(`protocol`.description, forHTTPHeaderField: WebSocket.Constants.headerWSProtocolName)
  }
  
  open func reportDidConnect() {
    callbackQueue.async {
      self.delegate?.websocketDidConnect(socket: self)
    }
  }
  
  open func write(string: String) {
    callbackQueue.async {
      self.delegate?.websocketDidReceiveMessage(socket: self, text: string)
    }
  }
  
  open func write(ping: Data, completion: (() -> ())?) {
  }

  public func disconnect() {
  }
  
  public func connect() {
  }
}
