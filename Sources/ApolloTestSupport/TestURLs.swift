import Foundation

/// URLs used in testing
public enum TestURL {
  case mockServer
  case starWarsServer
  case starWarsWebSocket
  case uploadServer
  
  public var url: URL {
    let urlString: String
    switch self {
    case .starWarsServer:
      urlString = "http://localhost:8080/graphql"
    case .starWarsWebSocket:
      urlString = "ws://localhost:8080/websocket"
    case .uploadServer:
      urlString = "http://localhost:4000"
    case .mockServer:
      urlString = "http://localhost/dummy_url"
    }
    
    return URL(string: urlString)!
  }
}
