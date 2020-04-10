import Starscream
import Foundation
@testable import ApolloWebSocket

class MockWebSocket: ApolloWebSocketClient {
  
  var callbackQueue: DispatchQueue = DispatchQueue.main
  
  var pongDelegate: WebSocketPongDelegate?
  var request: URLRequest
  
  var sslClientCertificate: SSLClientCertificate?
  
  required init(request: URLRequest, protocols: [String]?) {
    self.request = request
  }
  
  public init() {
    self.request = URLRequest(url: URL(string: "http://localhost:8080")!)
  }
  
  open func reportDidConnect() {
    callbackQueue.async {
      self.delegate?.websocketDidConnect(socket: self)
    }
  }
  
  open func write(string: String, completion: (() -> ())?) {
    callbackQueue.async {
      self.delegate?.websocketDidReceiveMessage(socket: self, text: string)
    }
  }
  
  open func write(data: Data, completion: (() -> ())?) {
  }
  
  open func write(ping: Data, completion: (() -> ())?) {
  }
  
  open func write(pong: Data, completion: (() -> ())?) {
  }
  
  func disconnect(forceTimeout: TimeInterval?, closeCode: UInt16) {
  }

  public var disableSSLCertValidation = false
  public var overrideTrustHostname = false
  public var desiredTrustHostname: String? = nil
  
  var delegate: WebSocketDelegate? = nil
  var security: SSLTrustValidator? = nil
  var enabledSSLCipherSuites: [SSLCipherSuite]? = []
  var isConnected: Bool = false
  
  func connect() {
  }
}
