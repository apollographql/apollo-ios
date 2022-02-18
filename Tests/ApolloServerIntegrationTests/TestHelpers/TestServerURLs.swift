/// Local URLs for servers used in integration testing
import Foundation

public enum TestServerURL: String {
  case mockServer = "http://localhost/dummy_url"
  case starWarsServer = "http://localhost:8080/graphql"
  case starWarsWebSocket = "ws://localhost:8080/websocket"
  case uploadServer = "http://localhost:4001"
  case subscriptionServer = "http://localhost:4000/graphql"
  case subscriptionWebSocket = "ws://localhost:4000/graphql"

  public var url: URL {
    return URL(string: self.rawValue)!
  }
}
