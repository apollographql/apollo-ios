import Starscream
import Foundation
@testable import ApolloWebSocket

public class MockWebSocket: ApolloWebSocketClient {
  
  public var callbackQueue: DispatchQueue = DispatchQueue.main
  
  // A dummy web socket since we can't just return the client
  var webSocketForDelegate: WebSocket
  public var request: URLRequest
    
  public required init(request: URLRequest,
                certPinner: CertificatePinning? = FoundationSecurity(),
                compressionHandler: CompressionHandler? = nil) {
    self.webSocketForDelegate = WebSocket(request: request)
    self.request = request
  }
  
  public init(request: URLRequest) {  
    self.request = request
    self.webSocketForDelegate = WebSocket(request: request)
  }
  
  open func reportDidConnect() {
    callbackQueue.async {
      self.delegate?.didReceive(event: .connected([:]), client: self.webSocketForDelegate)
    }
  }
  
  open func write(string: String, completion: (() -> ())?) {
    callbackQueue.async {
      self.delegate?.didReceive(event: .text(string), client: self.webSocketForDelegate)
    }
  }
  
  open func write(stringData: Data, completion: (() -> ())?) {
  }
  
  open func write(data: Data, completion: (() -> ())?) {
  }
  
  open func write(ping: Data, completion: (() -> ())?) {
  }
  
  open func write(pong: Data, completion: (() -> ())?) {
  }
  
  public func disconnect(closeCode: UInt16) {
  }
  
  public var delegate: WebSocketDelegate? = nil
  public var isConnected: Bool = false
  
  public func connect() {
  }
}
