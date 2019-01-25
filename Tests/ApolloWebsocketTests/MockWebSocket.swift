import Starscream
@testable import ApolloWebSocket

class MockWebSocket: ApolloWebSocketClient {
  var pongDelegate: WebSocketPongDelegate?
  
  var sslClientCertificate: SSLClientCertificate?
  
  required init(request: URLRequest, protocols: [String]?) {
  }
  
  public init() {
  }
  
  open func write(string: String, completion: (() -> ())?) {
    delegate?.websocketDidReceiveMessage(socket: self, text: string)
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
