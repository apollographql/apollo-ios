import Starscream
import Foundation
import ApolloTestSupport
@testable import ApolloWebSocket

class MockWebSocket: ApolloWebSocketClient {
  
  var callbackQueue: DispatchQueue = DispatchQueue.main
  
  // A dummy web socket since we can't just return the client
  var webSocketForDelegate: WebSocket
  var request: URLRequest
    
  required init(request: URLRequest,
                certPinner: CertificatePinning? = FoundationSecurity(),
                compressionHandler: CompressionHandler? = nil) {
    self.webSocketForDelegate = WebSocket(request: request)
    self.request = request
  }
  
  public init() {
    let request = URLRequest(url: TestURL.starWarsServer.url)
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
  
  func disconnect(closeCode: UInt16) {
  }
  
  var delegate: WebSocketDelegate? = nil
  var isConnected: Bool = false
  
  func connect() {
  }
}
