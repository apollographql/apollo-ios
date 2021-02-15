import Starscream
import Foundation

// MARK: - Client protocol

/// Protocol allowing alternative implementations of web sockets beyond `ApolloWebSocket`. Extends `Starscream`'s `WebSocketClient` protocol.
public protocol ApolloWebSocketClient: WebSocketClient {
  
  /// Required initializer
  ///
  /// - Parameters:
  ///   - request: The URLRequest to use on connection.
  ///   - protocols: [optional] The supported protocols. Should default to nil.
  ///   - certPinner: [optional] The object providing information about certificate pinning. Should default to Starscream's `FoundationSecurity`.
  ///   - compressionHandler: [optional] The object helping with any compression handling. Should default to nil.
  init(request: URLRequest,
       protocols: [String]?,
       certPinner: CertificatePinning?,
       compressionHandler: CompressionHandler?)

  /// The URLRequest used on connection.
  var request: URLRequest { get set }

  /// Queue where the callbacks are executed
  var callbackQueue: DispatchQueue { get set }
  
  var delegate: WebSocketDelegate? { get set }
}

// MARK: - WebSocket

/// Included implementation of an `ApolloWebSocketClient`, based on `Starscream`'s `WebSocket`.
public class ApolloWebSocket: WebSocket, ApolloWebSocketClient {
  
  private var transport: FoundationTransport!
  
  required public init(request: URLRequest,
                       protocols: [String]? = nil,
                       certPinner: CertificatePinning? = FoundationSecurity(),
                       compressionHandler: CompressionHandler? = nil) {
    var updatedRequest = request
    if let protocols = protocols,
       protocols.apollo.isNotEmpty {
      updatedRequest.setValue(protocols.joined(separator: ","), forHTTPHeaderField: "Sec-WebSocket-Protocol")
    }
    
    let engine = WSEngine(transport: FoundationTransport(),
                          certPinner: certPinner,
                          compressionHandler: compressionHandler)
    
    super.init(request: request, engine: engine)
  }
}
